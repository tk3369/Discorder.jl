# Control Plane

The control plane is a critical design component that powers the gateway interface. It maintains the state of the various async processes that interacts with Discord and provides an easy-to-use API to manage the lifecyle of these processes.

The gateway interface is implemented as multiple concurrent async processes:

1. **Heartbeat** task is an infinite loop that keeps sending heartbeat messages to the Discord server as part fo the gateway protocol. The elapsed time between each heartbeat is determined by an elapsed time value suggested by Discord server with a random jitter.

2. **Processor** task is an infinite loop that listens to messages coming from the gateway via a websocket connection. Messages include heartbeat acknowledgement messages as well as all other gateway events.

3. **Doctor** task is an infinite loop that monitors the health of heartbeat and processor tasks. If any of those tasks are broken then it will attempt to shut down both tasks and the control plane will restart everything automatically.

4. **Master** task is the one that starts Heartbeat, Processor, and Doctor tasks. It just waits until those tasks to finish.

The control plane normally runs in a loop. Suppose that the websocket connection got dropped for some reasons. The Doctor task detects the problem and decided that the system is not healthy. So, all tasks are shut down and the Master task also finishes. Then, the control plane starts everything all over again with a brand new connection to Discord. This design is intentionally made simple -- rather than attempting to recover individual failing components, it just restarts the entire thing.

The `fail_on_error` flag is a special configuration parameter that changes the behavior of this loop. Rather than trying to recover from failures and restart everything, the control plane just exits when an exception is thrown. This is more useful during development rather than in a production setting. For that reason, the flag is only enabled in the sample `dev.toml` config but not `prod.toml`.

## API

To run the control plane, make sure that the `DISCORD_BOT_TOKEN` environment variable is set.

Then, simply invoke the following function:

```julia
Discorder.run()
```

The function actually takes a couple of keyword parameters if you want more customization:

1. `client`: a BotClient object
2. `tracker_ref`: a `Ref` that will be populated in with a `GatewayTracker` object when the control plane starts can start successfully.
3. `config_file_path`: file path of the configuration file such as `dev.toml` or `prod.toml`. See `etc/` directory for sample configurations.

After the control plane starts successfully, the `GatewayTracker` object represents the current state, including references to all tasks mentioned above.  Here's how to test from REPL:

```julia
julia> D = Discorder
Discorder

julia> tracker_ref = Ref{D.GatewayTracker}()
Base.RefValue{Discorder.GatewayTracker}(#undef)

julia> client = D.BotClient()
BotClient(<token>, Discorder.RateLimiter(Dict{String, Discorder.Bucket}(), Dict{String, String}(), Discorder.WAIT))

julia> @async D.run(; client, tracker_ref, config_file_path = "etc/dev.toml")
Task (runnable) @0x00000001092088b0
```

At this point, the log file should be filled with events data. Check `Discorder.log`.

From the REPL, you can see what's going on with the control plane:
```julia
julia> tracker_ref
Base.RefValue{Discorder.GatewayTracker}(Discorder.GatewayTracker
  websocket: HTTP.WebSockets.WebSocket{HTTP.ConnectionPool.Transaction{MbedTLS.SSLContext}}
  heartbeat_interval_ms: Int64 41250
  seq: Int64 3
  heartbeat_task: Task
  processor_task: Task
  master_task: Task
  doctor_task: Task
  terminate_flag: Bool false
  fail_on_error: Bool true
  config: Dict{String, Any}
  stats: Discorder.GatewayStats
  publishers: Array{Discorder.AbstractEventPublisher}((0,))
)
```

To check if the control plane is healthy, use the `is_operational` function:
```julia
julia> D.is_operational(tracker_ref[])
true
```

You can also see some server statistics:
```julia
julia> tracker_ref[].stats
Discorder.GatewayStats
  start_time: TimeZones.ZonedDateTime
  ready_time: TimeZones.ZonedDateTime
  event_count: Int64 23
  published_event_count: Int64 9
  heartbeat_sent_count: Int64 14
  heartbeat_received_count: Int64 14
```

Notice there there are no publishers registered to the server. That means none of the gateway events are communicated to anyone. There are several publisher implementations in this package. See the `publishers` directory. For demo purpose, let's add a ZMQ publisher:

```julia
julia> D.add_event_publisher(tracker_ref[], D.ZMQPublisher(6000))
```

Then, start a subscriber from the REPL:
```julia
julia> using Sockets, ZMQ

julia> begin
           socket = Socket(SUB)
           subscribe(socket, "")
           connect(socket, "tcp://localhost:6000")
           while true
               msg = ZMQ.recv(socket) |> String
               @info "Received" msg
           end
       end
```

Now, go to Discord and enter a text message. I just entered "hello". The ZMQ subscriber now displays the following:
```
┌ Info: Received
└   msg = "MESSAGE_CREATE\t2022-09-11T16:17:41.535-07:00\t{\"member\":{\"avatar\":null,\"nick\":null,\"communication_disabled_until\":null,\"premium_since\":null,\"joined_at\":\"2022-02-10T07:40:03.886+00:00\",\"roles\":[\"980718892966088764\"],\"deaf\":false,\"pending\":false,\"mute\":false},\"nonce\":\"1018661642344333312\",\"timestamp\":\"2022-09-11T23:17:41.507+00:00\",\"embeds\":[],\"channel_id\":\"941237066015068163\",\"mention_everyone\":false,\"edited_timestamp\":null,\"author\":{\"avatar\":\"e99d41549a0f64ff8e7f02fa146d27b8\",\"id\":\"549374980488560651\",\"discriminator\":\"8593\",\"public_flags\":0,\"username\":\"tk3369\"},\"guild_id\":\"941237066015068160\",\"tts\":false,\"mentions\":[],\"pinned\":false,\"id\":\"1018661642990526504\",\"type\":0,\"content\":\"hello\",\"mention_roles\":[],\"attachments\":[]}"
```

The wire format contains a tab-delimited string with three components:
1. Event type e.g. `MESSAGE_CREATE`
2. Timestamp e.g. `2022-09-11T16:17:41.535-07:00`
3. JSON payload

The other publishers implementations are as follows:
* `ChannelEventPublisher`: publish events to a `Channel`
* `DelimitedFileEventPublisher`: publish events to a delimited file

Publishers should generally "fire-and-forget". However, please beware that if you use `ChannelEventPublisher`, then there is a possibility that the channel is full and you are blocked due to "back-pressure". For production usage, you can consider implemented your own non-blocking publisher (or contribute one to this package).

The control plane can auto-recover after connectivity problems. Let's simulate such a problem with the processor task in the REPL:

```julia
julia> @async Base.throwto(tracker_ref[].processor_task, ErrorException("simulated failure"))
Task (runnable) @0x000000016572a290
```

Checking the log file, you will find:
```
┌ Error: Processor loop error
│   ex = ErrorException("simulated failure")
│   current_time = 2022-09-11T16:36:45.365-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:381

┌ Info: Gateway is not healthy, stopping control plane
│   tracker = Discorder.GatewayTracker
│   current_time = 2022-09-11T16:36:45.960-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:251

┌ Info: Stopping task
│   task_field = processor_task
│   task = Task (done) @0x0000000174f71cd0
│   reason = auto recovery
│   current_time = 2022-09-11T16:36:46.040-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:405
┌ Info: Stopped task successfully
│   task_field = processor_task
│   task = Task (done) @0x0000000174f71cd0
│   current_time = 2022-09-11T16:36:46.119-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:415
┌ Info: Stopping task
│   task_field = heartbeat_task
│   task = Task (runnable) @0x0000000174f71b60
│   reason = auto recovery
│   current_time = 2022-09-11T16:36:46.165-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:405
┌ Info: Heartbeat task stopped by control plane
│   current_time = 2022-09-11T16:36:46.167-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:304
┌ Warning: Task already be set to nothing by control plane doctor?
│   task = nothing
│   label = processor
│   current_time = 2022-09-11T16:36:46.208-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:640
┌ Info: Finished master task
│   current_time = 2022-09-11T16:36:46.307-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:219
┌ Debug: Ensuring task is stopped
│   task_field = heartbeat_task
│   task = Task (done) @0x0000000174f71b60
│   reason = auto recovery
│   current_time = 2022-09-11T16:36:46.308-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:420
┌ Info: Stopped task successfully
│   task_field = heartbeat_task
│   task = Task (done) @0x0000000174f71b60
│   current_time = 2022-09-11T16:36:46.308-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:415
┌ Info: Finished doctor task
│   current_time = 2022-09-11T16:36:46.308-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:257
┌ Info: Control plane is finished
│   current_time = 2022-09-11T16:36:46.437-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:151
```

And then it shows that it started a new control plane:
```
┌ Info: Going to recover by starting a new control plane
│   current_time = 2022-09-11T16:36:47.443-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:160
```

The `shutdown` function can be used to shut down the control plane gracefully.

```julia
julia> D.shutdown(tracker_ref[])
┌ Info: Stopping task
│   task_field = :processor_task
│   task = Task (runnable) @0x0000000108bb95a0
└   reason = "graceful shutdown"
┌ Info: Stopped task successfully
│   task_field = :processor_task
└   task = Task (done) @0x0000000108bb95a0
┌ Info: Stopping task
│   task_field = :heartbeat_task
│   task = Task (runnable) @0x0000000108bb9430
└   reason = "graceful shutdown"
┌ Info: Stopped task successfully
│   task_field = :heartbeat_task
└   task = Task (done) @0x0000000108bb9430
```
