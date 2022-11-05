# Control Plane

The control plane is a critical design component that powers the gateway interface. It maintains the state of the various async processes that interacts with Discord and provides an easy-to-use API to manage the lifecyle of these processes.

The gateway interface is implemented as multiple concurrent async processes:

1. **Heartbeat** task is an infinite loop that keeps sending heartbeat messages to the Discord server as part fo the gateway protocol. The elapsed time between each heartbeat is determined by an elapsed time value suggested by Discord server with a random jitter.

2. **Processor** task is an infinite loop that listens to messages coming from the gateway via a websocket connection. Messages include heartbeat acknowledgement messages as well as all other gateway events.

3. **Doctor** task is an infinite loop that monitors the health of heartbeat and processor tasks. If any of those tasks are broken then it will attempt to shut down both tasks and the control plane will restart everything automatically.

4. **Master** task is the one that starts Heartbeat, Processor, and Doctor tasks. It just waits until those tasks to finish.

The control plane normally runs in a loop. Suppose that the websocket connection got dropped for some reasons. The Doctor task detects the problem and decided that the system is not healthy. So, all tasks are shut down and the Master task also finishes. Then, the control plane starts everything all over again with a brand new connection to Discord. This design is intentionally made simple -- rather than attempting to recover individual failing components, it just restarts the entire thing.

The `fail_on_error` flag is a special configuration parameter that changes the behavior of this loop. Rather than trying to recover from failures and restart everything, the control plane just exits when an exception is thrown. This is more useful during development rather than in a production setting. For that reason, the flag is only enabled in the sample `dev.toml` config but not `prod.toml`.

## Quick run

To run the control plane, make sure that the `DISCORD_BOT_TOKEN` environment variable is set.

Then, simply invoke the following function:

```julia
serve()
```

## Operating the control plane

The `serve` function actually takes a couple of keyword parameters if you want more customization:

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

julia> @async D.serve(; client, tracker_ref, config_file_path = "etc/dev.toml")
Task (runnable) @0x00000001092088b0
```

At this point, the log file should be filled with events data. Check the log file `dev.log`.

## Monitoring

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

## Adding publishers

By default, the control plane works as a ZMQ publisher. It binds to a default port (6000). If additional event publishing is required then you can add new publishers manually. For demo purpose, there are a few publishers in the `src/publishers` directory:
* `ChannelEventPublisher`: publish events to a `Channel`
* `DelimitedFileEventPublisher`: publish events to a delimited file

Publishers should generally "fire-and-forget". However, please beware that if you use `ChannelEventPublisher`, then there is a possibility that the channel is full and you are blocked due to "back-pressure". Keep that in mind for production usage as it could hang your control plane.

## Auto-recovery from task failures

The control plane can auto-recover after connectivity problems. Let's simulate such a problem with the processor task in the REPL:

```julia
julia> @async Base.throwto(tracker_ref[].processor_task, ErrorException("simulated failure"))
Task (runnable) @0x000000016572a290
```

In the log file, you will find that the control plane has detected the failure and restarted itself:
```
┌ Info: Starting a new control plane
│   current_time = 2022-09-11T16:36:47.443-07:00
└ @ Discorder /Users/tomkwong/.julia/dev/Discorder/src/gateway.jl:160
```

## Shutting down the control plane

The `shutdown` function can be used to shut down the control plane gracefully.

```julia
julia> D.shutdown(tracker_ref[])
```
