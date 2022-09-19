# Some ideas

## Independent gateway and bots (DONE)

The simplest architecture is to run both gateway and bot code in the same Julia runtime.
This approach, as normally done with previous Discord.jl packages, has a number of drawbacks:

1. The gateway process may be affected and its loops may be delayed if the bot code runs anything computationally intensive and does not yield (since the gateway runs as an async task). This issue exists with existing Xh4h's Discord.jl package although it can possibly be remediated if the bot code consciously spawns a separate thread to handle its logic.

2. If the bot code is erratic and needs to be restarted then the entire gateway needs to be restarted as well. Such coupling is unfortunate because it requires connecting to Discord server again.

3. If there are multiple bot components then these components share the same namespace unless sub-modules are used. Also, if one bot component misbehaves then it might affect other bot components.

So the basic idea is to just decouple everything:

- Gateway runs as a separate process and communicates events via ZMQ
- Each bot component runs as a separate process and receive events via ZMQ

So the gateway process can run forever and each bot component can start/stop whenever it comes to play. It is more scalable because gateway and bot components can technically run from a different container. In addition, it opens up the opportunity if you ever want to run the gateway process only but implement
bot components using a different language/runtime.

A demonstration of this idea can be found in the `example` folder.

## Declarative bot development

Perhaps a bot can be defined as a bunch of functions in a module?
Just like web servers, these functions need to be annotated with route
information. For simplicity reasons, macros matching Discord event types
can be used to register functions.

Currently, you must register handlers like this:
```julia
register!(bot, CommandTrigger(r",echo (.*)")) do client, message, str
    @info "Echo handler" str
    create_message(client, message.channel_id;
        content="ok, you said: $str",
        message_reference=MessageReference(message_id=message.id)
    )
end
```

It may be better to do this declaratively.

```julia
module MyBot

@message_create r",echo (.*)" function echo(client, message, str)
    @info "echo content = $str"
    return create_message(client, message.channel_id; content="ok, you said: $str")
end

@reaction_add r"([😄,😸])" function smile(client, emoji, emoji_name)
    @info "got smiley = $emoji_name"
end

end # module MyBot
```

Once a bot module is defined, pass the module (or modules in an array) to the `serve` function:

```julia
serve(MyBot, 6000; config_file_path="etc/dev.toml")
```
