# High level commands abstraction

Working with gateway directly is powerful but it would be nicer if there's a command-based interface. Rather than parsing strings all the time and dispatching to some function, perhaps it would be better to allow registering commands & arguments, similar to how CLIs are implemented. Another thought is that slash commands should be supported somehow.

Let's use HoJ bot as example:

,tz yyyy-mm-dd hh:mm:ss
,ig view
,ig perf
,ig chart aapl 2y
,ig buy 100 ibm
,ig sell 200 ibm
,discourse latest
,discourse traits

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

But, do we really need to separate them? Do we get a simpler interface otherwise?
E.g.

```julia
function configure_handler(
    id::Symbol, # a unique identifier for this handler
    f::Function, # function to be called
    trigger::AbstractTrigger, # when the function should be invoked
)::Handler
```

Then, the event loop is quite simple:
```julia
while true
    ev = get_next_event()
    active_handlers = filter(h -> should_trigger(h.trigger, ev), handlers)
    foreach(invoke_handler, active_handlers)
end
```

A trigger may be implemented with the following interface. It determines where the trigger is active for a specific gateway event.

```julia
should_invoke(t::AbstractTrigger, ev::Event)::Bool
```

What kinds of triggers are available? There could be prebuilt ones such as one that matches commands:

```julia
struct CommandTrigger <: AbstractTrigger
    prefix::Char
    regex::Regex  # matches starting 2nd character
end

# sample implementation
function should_invoke(t::CommandTrigger, ev::Event)
    if ev.type == "MESSAGE_CREATE"
        message = ev.data.content
        first(message) == t.prefix || return false
        rest = s[nextind(s, 1):end]
        return !isnothing(match(t.regex, rest))
    end
    return false
end
```

Here's another trigger for determining when an reaction is added/removed:
```julia
struct ReactionTrigger <: AbstractTrigger
    emoji_name::String
    operation::OperationEnum  # Add or Remove
end
```

Putting it together, this is how DevX looks like:
```julia
# Create a new Bot.
# 1. It needs a client object for handlers to make HTTP Discord requests
# 2. It needs a way to communcate with the control plane
bot = Bot(BotClient(), ZMQConnector(6000))

# Add handlers
prefix = ","
add_handler!(bot, juliadoc_handler, CommandTrigger(prefix, "echo"))

# Infinite loop
run_loop(bot)
```

And the handler:
```julia
function juliadoc_handler(
    # Allow the handler to interact with Discord e.g. sending a message
    client::BotClient,

    # The actual gateway event that happened
    ev::Event,

    # ---- after this point, arguments are customized by the Trigger ----

    # channel
    channel::DiscordChannel,

    # message
    message::Message,

    # parsed contains "hello world" if the Discord user typed ",echo hello world"
    # that's because CommandTrigger already parsed the command.
    # theoretically, it could pass more arguments when subcommands are matched
    parsed::String
)
    create_message(client, channel; content = "Got it: " * parsed)
end
```
