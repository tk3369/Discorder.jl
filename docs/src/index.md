# User Guide

Discorder.jl provides an easy way to write Discord bots in Julia.

## Control Plane

The control plane (which implements Discord Gateway interface) runs as an standalone process. It maintains a live connection to Discord and keeps a heartbeat process. It listens to events from Discord, for example, people sending messages or reacting to a message. Its primary duty is to publish these events to a ZMQ pub/sub channel. Starting the control plane server is simple:

```julia
using Discorder

serve(config_file_path="etc/dev.toml")
```

## Bot code

User code that runs bot custom logic can subscribe to the gateway events and register for specific patterns. For example, an "echo" bot can be written easily as such:

```julia
using Discorder

port = 6000
bot = Bot()

register_command_handler!(bot, CommandTrigger(r",echo (.*)")) do client, message, str
    create_message(client, message.channel_id;
        content="ok, you said: $str",
        message_reference=MessageReference(message_id=message.id)
    )
end

start(bot, port)
```

See `example` folder for the complete code and more bot examples.
