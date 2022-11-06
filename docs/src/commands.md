# High level commands abstraction

Working with gateway directly is powerful but it would be nicer if there's a command-based interface. Rather than parsing strings all the time and dispatching to some function, perhaps it would be better to allow registering commands & arguments, similar to how CLIs are implemented. Another thought is that slash commands should be supported somehow.

Let's use HoJ bot as example:

```
,tz yyyy-mm-dd hh:mm:ss
,ig view
,ig perf
,ig chart aapl 2y
,ig buy 100 ibm
,ig sell 200 ibm
,discourse latest
,discourse traits
```

Most of these are handled by matching some regex. So maybe we can take the command name & regex captures as a "command config". Prefix should be auto handled as well.

## Decoupling user code

The control plane is designed to run independently from user code.

Technically, the project could have been decoupled as well into three components:

1. Discorder Core Library - define core structs and API interfaces to Discord
2. Discorder Server - control plane implementation
3. Discorder Bot - tools for building bots

For sake of simplicity, the source code lives in the same repo for now.

For deployment, however, the control plane and user code should run in separate Julia processes. Something like this:

```
bash run_control_plane.sh &
bash run_hoj_bot.sh &
```


## Bot API design

The Bot API should support the following:

1. Configure a Bot
2. Register handlers to the Bot
3. Run event loop

It should be possible to start an event loop and still make changes afterwards. For example, a bot may allow guild owners to enable/disable certain bot functionalities and therefore handlers may be added/removed at runtime based upon configurations from a web-based user interfaces. So, the above sequence is really just for illustrative purpose rather than being prescriptive.

Learning from existing packages, Xh4H's Discord.jl has two kinds of integration:
- Command: invoke user code when someone types a message
- Handler: invokes user code some some kind of event happened e.g. reactions

Below is the current design.

First, create an instance of a bot. This object is used to keep track of the bot client as well as registered handlers. By default, the bot listens to port 6000 for ZMQ events. See [control plane doc](control_plane.md) about how to publish events from the Gateway using ZMQ.

```julia
bot = Bot()
```

Registering a command handler involves a command prefix and a regex to recognize the command itself. There are always two arguments passed to the user function: 1) bot client 2) discord object for that event.

```julia
julia> register_command_handler!(bot, CommandTrigger(',', r"echo ")) do client, message
           msg = strip(message.content[6:end])
           @info "message content = $msg"
           create_message(client, message.channel_id; content = "$msg")
       end
```

For illustration purpose, here's how to register a reaction handler, which would be called whenever a reaction add event is triggered.

```julia
julia> register_command_handler!(bot, ReactionAddTrigger()) do client, reaction_add_event
           @info "reaction event " reaction_add_event.emoji
       end
```

The bot must get into an event loop for processing. The `run` function can be used as such:

```julia
julia> play(bot)
```

