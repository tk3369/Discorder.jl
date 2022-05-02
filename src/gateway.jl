include("gateway/enums.jl")
include("gateway/error.jl")
include("gateway/session_start_limit.jl")
include("gateway/gateway.jl")
include("gateway/payload.jl")

const Optional{T} = Union{T,Nothing}

# Control plane request/response

abstract type AbstractControlRequest end
struct StartHeartbeatControlRequest <: AbstractControlRequest end
struct StopHeartbeatControlRequest <: AbstractControlRequest end

struct StartProcessorControlRequest <: AbstractControlRequest end
struct StopProcessControlRequest <: AbstractControlRequest end

abstract type AbstractControlResponse end

@enumx ControlResult OK FAILED
struct GeneralControlResponse <: AbstractControlResponse
    result::ControlResult.T
end

# Gateway tracker
@with_kw mutable struct GatewayTracker
    websocket::HTTP.WebSockets.WebSocket
    heartbeat_interval_ms::Int
    seq::Int
    heartbeat_task::Optional{Task} = nothing
    processor_task::Optional{Task} = nothing
    controller_task::Optional{Task} = nothing
    master_task::Optional{Task} = nothing
    doctor_task::Optional{Task} = nothing
    cin::Channel{AbstractControlRequest}
    cout::Channel{AbstractControlResponse}
    terminate_flag::Bool = false
end

struct GatewayError <: Exception
    message::String
end


function timed_logger()
    return TimestampTransformerLogger(
        current_logger(), BeginningMessageLocation();
        format = "yyyy-mm-dd HH:MM:SSz"
    )
end

# ---------------------------------------------------------------------------
# Control plane
#
# The control plane consists of the following async processes:
# 1. Controller: process external commands
# 2. Heartbeat: send heartbeat messages regularly to Discord gateway
# 3. Processor: receive and dispatch messages from Discord gateway
# 4. Doctor: monitor the health of the control plane and stop it when it's unhealthy
#
# The `run_control_plane` function starts a new control plane and wait for it to
# finish in a loop. Hence, if the doctor has diagnosed problems and stopped it,
# then a new control plane would come to live again.
# ---------------------------------------------------------------------------

"""
    start_control_plane(client::BotClient)

Start new control plane and return a `GatewayTracker` object.
"""
function start_control_plane(client::BotClient)
    local tracker
    with_logger(timed_logger()) do
        tracker_ready = Condition()
        task = @async begin
            gateway = get_gateway(client)
            url = "$(gateway.url)?v=$API_VERSION&encoding=json"
            @info "Connecting to gateway" url
            HTTP.WebSockets.open(url) do websocket
                json = readavailable(websocket)
                @debug "Received" json
                isempty(json) && throw(GatewayError("No data was received"))

                payload = JSON3.read(json, GatewayPayload)
                @info "Parsed" payload.op payload.d
                payload.op == GatewayOpcode.Hello || throw(GatewayError("Wrong opcode: $(payload.op)"))

                heartbeat_interval_ms = payload.d["heartbeat_interval"]
                seq = -1
                cin = Channel{AbstractControlRequest}(10)
                cout = Channel{AbstractControlResponse}(10)
                tracker = GatewayTracker(; websocket, heartbeat_interval_ms, seq, cin, cout)

                notify(tracker_ready)

                # Cannot exit this block or else the websocket would be closed
                # Let's just wait for the controller task which is supposed to be long running
                wait(start_controller(tracker))
            end
        end
        wait(tracker_ready)
        tracker.master_task = task

        # start necessary sub tasks
        start_heartbeat(tracker)
        start_processor(tracker)

        # make sure everything is up and running before starting doctor process
        wait_for_task_to_get_scheduled(tracker.heartbeat_task)
        wait_for_task_to_get_scheduled(tracker.processor_task)
        wait_for_task_to_get_scheduled(tracker.controller_task)
        start_doctor(tracker)
    end
    return tracker
end

# Run control plane in a loop so that we can actually auto-recover
function run_control_plane(client::BotClient, tracker_ref = Ref{GatewayTracker}())
    while true
        @info "Starting a new control plane"
        tracker_ref[] = start_control_plane(client)
        wait(tracker_ref[].master_task)
        tracker_ref[].terminate_flag && break
    end
    @info "Control plan has been fully shut down"
end

# The doctor is responsible for ensuring the healthiness of the control plane.
function start_doctor(tracker::GatewayTracker)
    tracker.doctor_task = @async begin
        while true
            if !is_operational(tracker)
                @info "Gateway is not healthy, stopping control plane" tracker
                stop_control_plane(tracker)
                break
            end
            sleep(1)
        end
    end
    return tracker.doctor_task
end

function send_payload(ws::HTTP.WebSockets.WebSocket, payload::GatewayPayload)
    try
        json = JSON3.write(payload)
        @debug "Sending payload" json
        write(ws, json)
        @debug "Finished sending payload"
    catch ex
        @error "Unable to send gateway payload: $ex"
        rethrow(ex)
    end
    return nothing
end

# ---------------------------------------------------------------------------
# Heartbeat
# ---------------------------------------------------------------------------

# See https://discord.com/developers/docs/topics/gateway#heartbeating
function start_heartbeat(tracker::GatewayTracker)
    tracker.heartbeat_task = @async try
        while true
            seq = tracker.seq < 0 ? nothing : tracker.seq
            payload = GatewayPayload(; op = GatewayOpcode.Heartbeat, d = seq)
            send_payload(tracker.websocket, payload)
            jitter = rand()  # should be between 0 and 1 per API Reference
            nap = tracker.heartbeat_interval_ms / 1000 * jitter
            @info "Sent heartbeat, taking a nap for $nap seconds"
            sleep(nap)
        end
        @debug "Finished heartbeat loop"
    catch ex
        if ex isa InterruptException
            @info "Heartbeat loop stopped by control plane"
        else
            @error "Heartbeat loop exited with error: $ex"
        end
    end
    return tracker.heartbeat_task
end

stop_heartbeat(tracker::GatewayTracker) = stop_task(tracker, :heartbeat_task)

# ---------------------------------------------------------------------------
# Processor
# ---------------------------------------------------------------------------

function start_processor(tracker::GatewayTracker)
    tracker.processor_task = @async try
        while true
            if isopen(tracker.websocket)
                json = readavailable(tracker.websocket)
                @debug "Received" json
                if !isempty(json)
                    payload = JSON3.read(json, GatewayPayload)
                    @debug "Parsed" payload.op payload.d
                else
                    @error "Received empty array"
                    break
                end
            else
                @error "oops, websocket is no longer open" tracker.websocket
                break
            end
        end
    catch ex
        if ex isa InterruptException
            @info "Processor loop stopped by control plane"
        else
            @error "Processor loop error: $ex"
        end
    end
    return tracker.processor_task
end

stop_processor(tracker::GatewayTracker) = stop_task(tracker, :processor_task)

# ---------------------------------------------------------------------------
# Control plane utils
# ---------------------------------------------------------------------------

# General function that can be used to stop any tasks in the GatewayTracker
# Return `true` if the task has been stopped successfully.
function stop_task(tracker::GatewayTracker, task_field::Symbol)
    task = getproperty(tracker, task_field)
    if isnothing(task)
        @info "Task does not exist anymore" task_field
        return true
    end
    @info "Stopping task" task_field task
    wait_seconds = 5
    sleep_time = 0.1
    max_iterations = wait_seconds / sleep_time
    cnt = 1
    try
        while cnt <= max_iterations
            @async Base.throwto(task, InterruptException())
            if istaskdone(task)
                setproperty!(tracker, task_field, nothing)
                @info "Stopped task successfully" task_field task
                return true
            end
            sleep(sleep_time)
            cnt += 1
            @debug "Ensuring task is stopped" task_field task
        end
        @error "Unable to stop task" task_field task
        return false
    catch ex
        @error "Unexpected exception while stopping task: $ex" task_field task
        return false
    end
end

# The controller continuously take commands from the input channel and execute
# respective commands. The command must be a subtype of AbstractControlRequest.
# Return the controller task.
#
# TODO processing each command can be done async as well.
function start_controller(tracker::GatewayTracker)
    tracker.controller_task = @async try
        while true
            # @info "Taking next request"
            request = take!(tracker.cin)
            # @info "Executing control request" request
            response = process(tracker, request)
            # @info "Putting result to output channel"
            put!(tracker.cout, response)
        end
        @info "Finished controller loop"
    catch ex
        if ex isa InterruptException
            @info "Controller loop stopped by control plane"
        else
            @error "Controller loop error: $ex"
        end
    end
    return tracker.controller_task
end

stop_controller(tracker::GatewayTracker) = stop_task(tracker, :controller_task)

function stop_control_plane(tracker::GatewayTracker)
    stop_processor(tracker)
    stop_heartbeat(tracker)
    stop_controller(tracker)
end

is_connected(tracker::GatewayTracker) = isopen(tracker.websocket)

is_task_runnable(t::Task) = istaskstarted(t) && !istaskdone(t)
is_task_runnable(::Nothing) = false   # stopped tasks has `nothing` value

function shutdown(tracker::GatewayTracker)
    tracker.terminate_flag = true
    stop_control_plane(tracker)
end

function is_operational(tracker::GatewayTracker)
    return is_task_runnable(tracker.controller_task) &&
        is_task_runnable(tracker.heartbeat_task) &&
        is_task_runnable(tracker.processor_task) &&
        is_connected(tracker)
end

# === Control Requests ===

# In general, tasks started with @async should be schedulded immediately.
# But if it doesn't, then we can wait a little bit before giving up.
function wait_for_task_to_get_scheduled(task::Task)
    cnt = 0
    while cnt < 50
        if istaskstarted(task)
            @debug "Task scheduled!" task
            return true
        end
        cnt += 1
        sleep(0.1)
    end
    if istaskfailed(task)
        @error "waiting for task to be scheduled but it failed" task
        return false
    end
    @error "waiting for task to be scheduled but it never got started" task
    @async Base.throwto(task, InterruptException())
    return false
end

function process end

# func: must return a Task object
function _start_process(tracker::GatewayTracker, task_field::Symbol, func::Base.Callable)
    task = func(tracker)
    ok = wait_for_task_to_get_scheduled(task)
    if ok
        setproperty!(tracker, task_field, task)
        return GeneralControlResponse(ControlResult.OK)
    else
        return GeneralControlResponse(ControlResult.FAILED)
    end
end

# func: must return a bool
function _stop_process(tracker::GatewayTracker, task_field::Symbol, func::Base.Callable)
    ok = func(tracker)
    if ok
        setproperty!(tracker, task_field, nothing)  # not needed? do it just in case.
        return GeneralControlResponse(ControlResult.OK)
    else
        return GeneralControlResponse(ControlResult.FAILED)
    end
end

function process(tracker::GatewayTracker, ::StartHeartbeatControlRequest)
    _start_process(tracker, :heartbeat_task, start_heartbeat)
end

function process(tracker::GatewayTracker, ::StopHeartbeatControlRequest)
    _stop_process(tracker, :heartbeat_task, stop_heartbeat)
end

function process(tracker::GatewayTracker, ::StartProcessorControlRequest)
    _start_process(tracker, :processor_task, start_processor)
end

function process(tracker::GatewayTracker, ::StopProcessControlRequest)
    _stop_process(tracker, :processor_task, stop_processor)
end


#=
The controller idea is probably the best way to keep the connection alive.
Or we can call it the control plane.

It monitors sub-processes (heartbeat, processor, etc) and the state of the websocket.
If anything goes wrong then it can close the websocket and start over.
So the procedure looks like:

control plane init:
1. get gateway url

"start" command:
1. open web socket and start heartbeat & processor loops
2. open

=#
