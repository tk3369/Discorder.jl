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

```
Discorder.run()
```

The function actually takes a couple of keyword parameters if you want more customization:

1. `client`: a BotClient object
2. `tracker_ref`: a `Ref` that will be populated in with a `GatewayTracker` object when the control plane starts can start successfully.
3. `config_file_path`: file path of the configuration file such as `dev.toml` or `prod.toml`. See `etc/` directory for sample configurations.

After the control plane starts successfully, the `GatewayTracker` object represents the current state, including references to all tasks mentioned above. If you are testing it from a Julia REPL, then you can operate the control plane using various management functions. For examples:

* `is_operational` returns `true` if the control plane is in a healthy state.
* `shutdown` shuts down the control plane gracefully.
