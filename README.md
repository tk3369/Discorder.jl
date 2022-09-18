# Discorder

[![HoJ Discord](https://img.shields.io/discord/762167454973296644?color=8af&label=HoJ%20Discord&style=flat-square)](https://discord.gg/mm2kYjB)
![Status](https://img.shields.io/badge/status-work%20in%20progress-yellow)

Write [Discord](https://discord.com) bots in [Julia](https://julialang.org). This package is the most complete and up-to-date implementation of the Discord API for Julia.

## Project goals

Previous attempts were great but had problem with runtime connection instabilities and difficulties in keeping up with Discord API changes. Learning from those experiences, the goals of this project includes:

1. Supports the latest version of the Discord API (version 10 as of June 2022).
2. Have a solid control plane for the gateway interface, which is error-resilient and can auto-recover from connectivity problems.
3. Ability to decouple user code from the control plane, so problems with user code do not necessarily affect the operation of control plane.
4. Have a high-level API that makes it easy to develop and operate a Discord bot.

## Current status

Here is the list of features:
- [x] Discord v10 API support (reconciled in June 2022)
- [x] Gateway connectivity and auto-recovery from connection problems
- [x] System management via control plane
- [x] Event publisher (local channel, file-based, and ZMQ pub/sub)
- [ ] High level command/handler API like those in Xh4H Discord.jl
- [ ] Gateway resume (it currently opens a new connection during recovery)
- [ ] Audit log header (required for certain API calls since v10)
- [ ] Slash commands

## TL;DR - how to operate a Discord bot

The control plane (which implements Discord Gateway interface) runs as an standalone process. It maintains a live connection to Discord and keeps a heartbeat process. It listens to events from Discord, for example, people sending messages or reacting to a message. It's primary duty is to publish these events to a ZMQ pub/sub channel. Starting the control plane server is simple:

```julia
port = 6000
cfg = "etc/dev.toml"
serve(config_file_path=cfg, publisher=ZMQPublisher(port))
```

User code that runs bot custom logic can subscribe to the gateway events and register for specific patterns. For example, an "echo" bot can be written easily as such:

```julia
port = 6000
bot = Bot()

register!(bot, CommandTrigger(r",echo (.*)")) do client, message, str
    create_message(client, message.channel_id;
        content="ok, you said: $str",
        message_reference=MessageReference(message_id=message.id)
    )
end

start(bot, port)
```

See `example` folder for the complete code and more bot examples.

## History

[Xh4H](https://github.com/Xh4H) and [Chris de Graaf](https://github.com/christopher-dG) previously implemented the [Xh4H/Discord.jl package](https://github.com/Xh4H/Discord.jl), but it was never published in the Julia registry for several reasons.

Chris started a [new Discord.jl project](https://github.com/christopher-dG/Discord.jl) in 2020 to keep things as simple as possible and minimize extra features in order to maximize maintainability as the Discord API changes. It also aims to be easily extensible, so that packages providing extra features can be written on top of it. However, Chris could not find time to continue working on the project.

[@xxxAnn](https://github.com/xxxAnn) forked Xh4H's Discord.jl package late 2021 in an attempt to update the API to the latest version. The project is called [Ekztazy.jl](https://github.com/Humans-of-Julia/Ekztazy.jl).

[Tom](https://github.com/tk3369) forked Chris' project in 2022 in the light of Discord's plan to decommision version 6 of their API. To avoid confusion to Xh4H and Chris' previous implementations, this package has been renamed to Discorder.jl.
