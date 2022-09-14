# Some ideas

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
