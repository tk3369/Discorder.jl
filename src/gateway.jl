"""
    GatewayTracker

GatewayTracker is a stateful object used by the Control Pane.
"""
@with_kw mutable struct GatewayTracker
    "The websocket connection to Discord gateway."
    websocket::Optional{HTTP.WebSockets.WebSocket} = nothing

    """
    The approximate time in milliseconds between every heartbeat. While it has a
    default value, the interval is normally established with the suggested value
    after connecting to the gateway.
    """
    heartbeat_interval_ms::Int = 60_000

    "The sequence number for keeping track of received messages from gateway."
    seq::Int = -1

    "Background task for sending heartbeat messages."
    heartbeat_task::Optional{Task} = nothing

    "Background task for receiving and processing incoming messages."
    processor_task::Optional{Task} = nothing

    "Foreground task that runs the main loop."
    master_task::Optional{Task} = nothing

    "Background maintenance task for detecting and recovering from connection problems."
    doctor_task::Optional{Task} = nothing

    "An internal flag to terminate the control pane. Do not use."
    terminate_flag::Bool = false

    "The `ready` flag is set to `true` after the gateway has been connected."
    ready::Bool = false

    """
    The `events` channel is used for communicating gateway events to end users.
    """
    events::Channel = Channel{Event}()

    """
    Throw exception and exit control pane when any exception is encountered.
    This is useful for during development. When this is set to false, exceptions
    are generally swallowed but reported so they appear in the log file.
    """
    fail_on_error::Bool = false
end

function GatewayTracker(config)
    isnothing(config) && return GatewayTracker()
    fail_on_error = get_config(config, "fail_on_error")
    event_queue_size = get_config(config, "event_queue_size")
    events = Channel{Event}(event_queue_size)
    return GatewayTracker(; fail_on_error, events)
end

function get_config(config, key)
    # default config mimics production settings
    default_config = Dict(
        "fail_on_error" => true, "event_queue_size" => 1024, "debug" => false
    )
    return haskey(config, key) ? config[key] : default_config[key]
end

function read_gateway_config(config_file_path::AbstractString)
    try
        config = TOML.parse(String(read(config_file_path)))
        gateway_config = config["gateway"]
        @info "Gateway config settings" gateway_config
        return gateway_config
    catch ex
        @error "Unable to read gateway config" config_file_path ex
        error("Unable to read gateway config ($config_file_path): $ex")
    end
end

struct GatewayError <: Exception
    message::String
end

function make_gateway_url(client::BotClient, version=API_VERSION)
    gateway = get_gateway(client)
    return "$(gateway.url)?v=$version&encoding=json"
end

# ---------------------------------------------------------------------------
# Control plane
#
# The control plane consists of the following async processes:
# 1. Heartbeat: send heartbeat messages regularly to Discord gateway
# 2. Processor: receive and dispatch messages from Discord gateway
# 3. Doctor: monitor the health of the control plane and stop it when it's unhealthy
#
# The `run_control_plane` function starts a new control plane and wait for it to
# finish in a loop. Hence, if the doctor has diagnosed problems and stopped it,
# then a new control plane would come to live again.
# ---------------------------------------------------------------------------

"""
    run_control_plane(;
        client::BotClient=BotClient(),
        tracker_ref=Ref{GatewayTracker}(),
        config_file_path::Optional{AbstractString}=nothing,
    )

Run control plane in a loop so that we can actually auto-recover when
bad things happen.
"""
function run_control_plane(;
    client::BotClient=BotClient(),
    tracker_ref=Ref{GatewayTracker}(),
    config_file_path::Optional{AbstractString}=nothing,
)
    if !isnothing(config_file_path)
        config = read_gateway_config(config_file_path)
        debug = get_config(config, "debug")
    else
        config = nothing
        debug = false
    end
    with_logger(get_logger(; debug)) do
        while true
            @info "Starting a new control plane"
            elapsed_seconds = @elapsed tracker_ref[] = start_control_plane(client, config)
            @info "Started control plane" elapsed_seconds
            safe_wait(tracker, tracker_ref[].master_task, :master)
            if tracker_ref[].terminate_flag
                @info "Terminate flag is set to true, exiting control pane loop."
                break
            elseif tracker_ref[].fail_on_error
                @info "Fail on error flag is set to true, exiting control pane loop."
                break
            end
        end
        @info "Control plan has been shut down completely."
    end
end

"""
    start_control_plane(client::BotClient, config)

Start new control plane and return a `GatewayTracker` object.
"""
function start_control_plane(client::BotClient, config)
    tracker = GatewayTracker(config)
    tracker_ready = Condition()
    task = @async try
        gateway_url = make_gateway_url(client)
        @info "Connecting to gateway" gateway_url

        HTTP.WebSockets.open(gateway_url) do websocket
            tracker.websocket = websocket

            # https://discord.com/developers/docs/topics/gateway#connecting
            # Once connected, the client should immediately receive an Opcode 10 Hello payload
            json = String(readavailable(websocket))
            @debug "Received" json
            isempty(json) && throw(GatewayError("No data was received"))

            payload = safe_parse_json(tracker, json, GatewayPayload)
            isnothing(payload) && throw(GatewayError("Unable to parse payload"))

            @debug "Parsed" payload.op payload.d
            payload.op == GatewayOpcode.Hello ||
                throw(GatewayError("Wrong gateway opcode: $(payload.op)"))

            tracker.heartbeat_interval_ms = payload.d["heartbeat_interval"]

            # https://discord.com/developers/docs/topics/gateway#identifying
            send_identify(tracker)

            @debug "Starting heartbeat and processor tasks"
            start_heartbeat(tracker)
            start_processor(tracker)
            notify(tracker_ready)

            @debug "Waiting for heartbeat and processor tasks"
            @debug "heartbeat_task = $(tracker.heartbeat_task)"
            @debug "processor_task = $(tracker.processor_task)"
            safe_wait(tracker, tracker.heartbeat_task, :heartbeat)
            safe_wait(tracker, tracker.processor_task, :processor)

            @info "Finished master task"
        end
    catch ex
        @error "Unable to start control plane (phase 1): $ex"
        show_error(ex)
        fail_on_error && rethrow(ex)
    end

    try
        @debug "Waiting for tracker to be ready"
        safe_wait(tracker, tracker_ready, :init_process)

        tracker.master_task = task

        # make sure everything is up and running before starting doctor process
        @debug "Waiting for heartbeat task to get started"
        wait_for_task_to_get_scheduled(tracker.heartbeat_task, :heartbeat)

        @debug "Waiting for processor task to get started"
        wait_for_task_to_get_scheduled(tracker.processor_task, :processor)

        @debug "Starting doctor task"
        start_doctor(tracker)
        wait_for_task_to_get_scheduled(tracker.doctor_task, :doctor)

        @info "Control plane started successfully" tracker
    catch ex
        @error "Unable to start control plane (phase 2): $ex"
        show_error(ex)
        fail_on_error && rethrow(ex)
    end
    return tracker
end

function default_token()
    token = get(ENV, "DISCORD_BOT_TOKEN", "")
    isempty(token) && error("Please define DISCORD_BOT_TOKEN environemnt variable.")
    return token
end

# https://discord.com/developers/docs/topics/gateway#identifying
function send_identify(tracker::GatewayTracker)
    @info "Sending IDENTIFY payload"
    payload = GatewayPayload(;
        op=GatewayOpcode.Identify,
        d=Identify(;
            token=default_token(),
            intents=Int(0x01ffff),
            properties=IdentifyConnectionProperties(;
                os_="linux", browser_="Discorder", device_="Discorder"
            ),
        ),
    )
    return send_payload(tracker, payload)
end

# The doctor is responsible for ensuring the healthiness of the control plane.
function start_doctor(tracker::GatewayTracker)
    tracker.doctor_task = @async try
        while true
            if !is_operational(tracker)
                @info "Gateway is not healthy, stopping control plane" tracker
                sleep(1)
                stop_control_plane(tracker, "auto recovery")
                break
            end
            sleep(1)
        end
        @info "Finished doctor task"
    catch ex
        @error "Unexpected exception in doctor task: $ex"
        show_error(ex)
        tracker.fail_on_error && rethrow(ex)
    end
    return tracker.doctor_task
end

function send_payload(tracker::GatewayTracker, payload::GatewayPayload)
    try
        str = json(payload)
        @debug "Sending payload" sanitize(str)
        write(tracker.websocket, str)
        @debug "Finished sending payload"
    catch ex
        @error "Unable to send gateway payload: $ex"
        show_error(ex)
        tracker.fail_on_error && rethrow(ex)
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
            # Setting seq to `nothing` would force sending a `null`. See doc:
            # https://discord.com/developers/docs/topics/gateway#heartbeat
            seq = tracker.seq < 0 ? nothing : tracker.seq
            payload = GatewayPayload(; op=GatewayOpcode.Heartbeat, d=seq)
            send_payload(tracker, payload)
            jitter = rand()  # should be between 0 and 1 per API Reference
            nap = tracker.heartbeat_interval_ms / 1000 * jitter
            @info "Sent heartbeat, taking nap now." nap
            sleep(nap)
        end
        @debug "Finished heartbeat task"
    catch ex
        if ex isa InterruptException
            @info "Heartbeat task stopped by control plane"
        else
            @error "Heartbeat task exited with error" ex
            show_error(ex)
            tracker.fail_on_error && rethrow(ex)
        end
    end
    return tracker.heartbeat_task
end

function stop_heartbeat(tracker::GatewayTracker, reason::String)
    return stop_task(tracker, :heartbeat_task, reason)
end

# ---------------------------------------------------------------------------
# Processor
# ---------------------------------------------------------------------------

function start_processor(tracker::GatewayTracker)
    tracker.processor_task = @async try
        while true
            if isopen(tracker.websocket)
                json = String(readavailable(tracker.websocket))
                @debug "Received" json
                if !isempty(json)
                    payload = safe_parse_json(tracker, json, GatewayPayload)
                    # If there's any parsing issue then continue loop
                    # TODO perhaps the Discorder user should have an option to throw?
                    isnothing(payload) && continue
                    @debug "Parsed" payload.op payload.t payload.d payload.s
                    if payload.s isa Integer
                        tracker.seq = payload.s  # sync sequence number
                    end
                    if payload.op === GatewayOpcode.Resume
                        # https://discord.com/developers/docs/topics/gateway#resumed
                        object = Event("RESUME")
                        put!(tracker.events, object)
                    elseif payload.op === GatewayOpcode.Reconnect
                        # https://discord.com/developers/docs/topics/gateway#reconnect
                        object = Event("RECONNECT")
                        put!(tracker.events, object)
                        stop_control_plane(tracker, "Discord wants me to reconnect")
                    elseif payload.op === GatewayOpcode.InvalidSession
                        # https://discord.com/developers/docs/topics/gateway#invalid-session
                        object = make_object(
                            tracker, "INVALID_SESSION", JSON3.write(payload.d)
                        )
                        !isnothing(object) && put!(tracker.events, object)
                    elseif !isnothing(payload.t) && !isnothing(payload.d)
                        object = make_object(tracker, payload.t, JSON3.write(payload.d))
                        !isnothing(object) && put!(tracker.events, object)
                    end
                else
                    @error "Received empty array"
                    break
                end
            else
                @error "oops, websocket is no longer open" tracker.websocket
                break
            end
        end
        @info "Finished processor task"
    catch ex
        if ex isa InterruptException
            @info "Processor loop stopped by control plane"
        else
            @error "Processor loop error" ex
            show_error(ex)
            tracker.fail_on_error && rethrow(ex)
        end
    end
    return tracker.processor_task
end

function stop_processor(tracker::GatewayTracker, reason::String)
    return stop_task(tracker, :processor_task, reason)
end

# ---------------------------------------------------------------------------
# Control plane utils
# ---------------------------------------------------------------------------

# General function that can be used to stop any tasks in the GatewayTracker
# Return `true` if the task has been stopped successfully.
function stop_task(tracker::GatewayTracker, task_field::Symbol, reason::String)
    task = getproperty(tracker, task_field)
    if isnothing(task)
        @info "Task does not exist anymore" task_field reason
        return true
    end
    @info "Stopping task" task_field task reason
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
        @error "Unexpected exception while stopping task" ex task_field task
        show_error(ex)
        tracker.fail_on_error && rethrow(ex)
        return false
    end
end

function stop_control_plane(tracker::GatewayTracker, reason::String)
    stop_processor(tracker, reason)
    stop_heartbeat(tracker, reason)
    return nothing
end

is_connected(tracker::GatewayTracker) = isopen(tracker.websocket)

is_task_runnable(t::Task) = istaskstarted(t) && !istaskdone(t)
is_task_runnable(::Nothing) = false   # stopped tasks has `nothing` value

function shutdown(tracker::GatewayTracker)
    tracker.terminate_flag = true
    stop_control_plane(tracker, "graceful shutdown")
    return nothing
end

function is_operational(tracker::GatewayTracker)
    if !is_connected(tracker)
        @error "Websocket already closed"
        return false
    end
    if !is_task_runnable(tracker.heartbeat_task)
        @error "Heartbeat task not running anymore"
        return false
    end
    if !is_task_runnable(tracker.processor_task)
        @error "Processor task not running anymore"
        return false
    end
    return true
end

doctor_around(tracker::GatewayTracker) = is_task_runnable(tracker.doctor_task)

# In general, tasks started with @async should be schedulded immediately.
# But if it doesn't, then we can wait a little bit before giving up.
function wait_for_task_to_get_scheduled(task::Task, label::Symbol)
    max_wait_time = Second(30)
    start_ts = now()
    while true
        elapsed = now() - start_ts
        elapsed > max_wait_time && break
        if istaskstarted(task)
            @info "Task scheduled!" task label elapsed
            return nothing
        end
        sleep(0.1)
    end
    @warn "waiting for task to be scheduled but it never got started" task
    return nothing
end

function event_object_mappings()
    return Dict(
        # https://discord.com/developers/docs/topics/gateway#ready
        "READY" => ReadyEvent,

        # https://discord.com/developers/docs/topics/gateway#guilds
        "GUILD_CREATE" => Guild,
        "GUILD_UPDATE" => Guild,
        "GUILD_DELETE" => UnavailableGuild,
        "GUILD_ROLE_CREATE" => GuildRoleCreateEvent,
        "GUILD_ROLE_UPDATE" => GuildRoleUpdateEvent,
        "GUILD_ROLE_DELETE" => GuildRoleDeleteEvent,

        # https://discord.com/developers/docs/topics/gateway#channels
        "CHANNEL_CREATE" => DiscordChannel,
        "CHANNEL_UPDATE" => DiscordChannel,
        "CHANNEL_DELETE" => DiscordChannel,
        "CHANNEL_PINS_UPDATE" => ChannelPinsUpdateEvent,
        "THREAD_CREATE" => Channel,
        "THREAD_UPDATE" => DiscordChannel,
        "THREAD_DELETE" => DiscordChannel,
        "THREAD_LIST_SYNC" => ThreadListSyncEvent,
        "THREAD_MEMBER_UPDATE" => ThreadMember,
        "THREAD_MEMBERS_UPDATE" => ThreadMembersUpdateEvent,

        # https://discord.com/developers/docs/topics/gateway#stage-instances
        "STAGE_INSTANCE_CREATE" => StageInstance,
        "STAGE_INSTANCE_UPDATE" => StageInstance,
        "STAGE_INSTANCE_DELETE" => StageInstance,

        # https://discord.com/developers/docs/topics/gateway#guild-member-add
        "GUILD_MEMBER_ADD" => GuildMember,
        "GUILD_MEMBER_UPDATE" => GuildMemberUpdateEvent,
        "GUILD_MEMBER_REMOVE" => GuildMemberRemoveEvent,

        # https://discord.com/developers/docs/topics/gateway#guild-ban-add
        "GUILD_BAN_ADD" => GuildBanAddEvent,
        "GUILD_BAN_REMOVE" => GuildBanRemoveEvent,
        "GUILD_EMOJIS_UPDATE" => GuildEmojisUpdateEvent,
        "GUILD_STICKERS_UPDATE" => GuildStickersUpdateEvent,

        # https://discord.com/developers/docs/topics/gateway#guild-integrations-update
        "GUILD_INTEGRATIONS_UPDATE" => GuildIntegrationsUpdateEvent,
        "INTEGRATION_CREATE" => Integration,
        "INTEGRATION_UPDATE" => Integration,
        "INTEGRATION_DELETE" => IntegrationDeleteEvent,

        # https://discord.com/developers/docs/topics/gateway#invites
        "INVITE_CREATE" => InviteCreateEvent,
        "INVITE_DELETE" => InviteDeleteEvent,

        # https://discord.com/developers/docs/topics/gateway#presence
        "PRESENCE_UPDATE" => PresenceUpdateEvent,

        # https://discord.com/developers/docs/topics/gateway#messages
        "MESSAGE_CREATE" => Message,
        "MESSAGE_UPDATE" => Message,
        "MESSAGE_DELETE" => MessageDeleteEvent,
        "MESSAGE_DELETE_BULK" => MessageDeleteBulkEvent,

        # https://discord.com/developers/docs/topics/gateway#message-reaction-add
        "MESSAGE_REACTION_ADD" => MessageReactionAddEvent,
        "MESSAGE_REACTION_REMOVE" => MessageReactionRemoveEvent,
        "MESSAGE_REACTION_REMOVE_ALL" => MessageReactionRemoveAllEvent,
        "MESSAGE_REACTION_REMOVE_EMOJI" => MessageReactionRemoveEmojiEvent,

        # https://discord.com/developers/docs/topics/gateway#typing-start
        "TYPING_START" => TypingStartEvent,

        # https://discord.com/developers/docs/topics/gateway#guild-scheduled-event-create
        "GUILD_SCHEDULED_EVENT_CREATE" => GuildScheduledEvent,
        "GUILD_SCHEDULED_EVENT_UPDATE" => GuildScheduledEvent,
        "GUILD_SCHEDULED_EVENT_DELETE" => GuildScheduledEvent,
        "GUILD_SCHEDULED_EVENT_USER_ADD" => GuildScheduledEventUserAddEvent,
        "GUILD_SCHEDULED_EVENT_USER_REMOVE" => GuildScheduledEventUserRemoveEvent,

        # https://discord.com/developers/docs/topics/gateway#voice-state-update
        "VOICE_STATE_UPDATE" => VoiceState,
        "VOICE_SERVER_UPDATE" => VoiceServerUpdateEvent,
    )
end

function parse_event(
    tracker::GatewayTracker, event_type::AbstractString, json::Optional{AbstractString}
)
    mappings = event_object_mappings()
    T = haskey(mappings, event_type) ? mappings[event_type] : Any
    object = safe_parse_json(tracker, json, T)
    isnothing(object) && @error "Skipping event due to parsing issue" event_type json
    return object
end

"""
    make_object(tracker::GatewayTracker, event_type::AbstractString, json::Optional{AbstractString})

Create an event object.
"""
function make_object(
    tracker::GatewayTracker, event_type::AbstractString, json::Optional{AbstractString}
)
    object = parse_event(tracker, event_type, json)
    return Event(event_type, object)
end

"""
    safe_parse_json(tracker::GatewayTracker, json::AbstractString, T::DataType)

Parse a JSON string into an expected type `T`, which is configured using StructType traits.
Returns `nothing` if the string cannot be parsed for some reasons. Throw exception only
during `fail_on_error` mode.
"""
function safe_parse_json(tracker::GatewayTracker, json::AbstractString, T::DataType)
    try
        return JSON3.read(json, T)
    catch ex
        @error "Unable to parse JSON string" json T ex
        show_error(ex)
        tracker.fail_on_error && rethrow(ex)
    end
    return nothing
end

"""
    safe_wait(task::Optional{Task})

Wait for a task for finish synchronously. Unlike `wait`, it is meant to be safe and never
throw, except during `fail_on_error` mode. Always return `nothing`.
"""
function safe_wait(tracker::GatewayTracker, task, label)
    if isnothing(task)
        @warn "Task already be set to nothing by control plane doctor?" task label
    else
        try
            wait(task)
        catch ex
            @error "Unable to wait for task" task ex label
            show_error(ex)
            fail_on_error && rethrow(ex)
        end
    end
    return nothing
end
