# Some ideas

## Independent gateway and bots

The simplest architecture is to run both gateway and bot code in the same Julia runtime.
This approach, as normally done with previous Discord.jl packages, has a number of drawbacks:

1. The gateway process may be affected and its loops may be delayed if the bot code runs anything computationally intensive and does not yield (since the gateway runs as an async task). This issue exists with existing Xh4h's Discord.jl package although it can possibly be remediated if the bot code spawns a separate thread handle its logic.

2. If the bot code is erratic and needs to be restarted then the entire gateway needs to be restarted as well. This coupling is unfortunate because gateway code is expected to be rock solid and run for a long time.

3. If there are multiple bot components then these components share the same namespace unless sub-modules are used. Also, if one bot component misbehaves then it might affect other bot components.

So the idea is that we decouple everything:

- Gateway runs as a separate process and communicates events via ZMQ
- Each bot component runs as a separate process and receive events via ZMQ

So the gateway process can run forever and each bot component can start/stop whenever it comes to play.
In addition, it opens up the opportunity if someone wants to run the gateway process only, and implement
bot components using a different language/runtime.

## Declarative bot development

Perhaps a bot can be defined as a bunch of functions in a module?
Just like web servers, these functions need to be annotated with route
information. For simplicity reasons, macros matching Discord event types
are used to register functions.

```julia
using Discorder

module MyBot

@message_create r",echo (.*)" function echo(client, message, str)
    @info "echo content = $str"
    return create_message(client, message.channel_id; content="ok, you said: $str")
end

@reaction_add r"([😄,😸])" function smile(client, emoji, emoji_name)
    @info "got smiley = $emoji_name"
end

end # module MyBot

serve(MyBot, 6000; config_file_path="etc/dev.toml")
```
