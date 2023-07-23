# Discorder

[![HoJ Discord](https://img.shields.io/discord/762167454973296644?color=8af&label=HoJ%20Discord&style=flat-square)](https://discord.gg/mm2kYjB)
![Status](https://img.shields.io/badge/status-work%20in%20progress-yellow)
[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://tk3369.github.io/Discorder.jl/dev/)


Write [Discord](https://discord.com) bots in [Julia](https://julialang.org). This package is currently the most complete and up-to-date implementation of the Discord API for Julia.

## Architecture

The primary difference between this and other Julia Discord libraries is that it has a separate control plane that primarily works with [Discord Gateway](https://discord.com/developers/docs/topics/gateway). This control plane continuously monitor activities from your Discord server and publish events.

Discord bots run as separate processes. You may operate multiple bots independently of each other. They all share the same events stream from the control plane.

![Architecture Diagram](docs/src/images/architecture.png)

Source is located in [Excalidraw](https://excalidraw.com/#json=6qjuNGHAiq_8s9QZC0yYN,BWOwo-Y4aIQEK5rApC3z0A).

## Quick start

Starting the control requires a simple config file. You can find examples configs in the [etc folder of this repo](etc).

```julia
using Discorder
serve(config_file_path="etc/dev.toml")
```

Bot clients can subscribe to the events and register for specific event patterns. For example, an "echo" bot can be written easily as such:

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

See `example` folder for more bot examples.

## Project goals

Previous attempts were great but had problem with runtime connection instabilities and difficulties in keeping up with Discord API changes. Learning from those experiences, the goals of this project includes:

1. Ability to update to the latest Discord API easily
2. Have a solid control plane for the gateway interface that is error-resilient and can auto-recover from connectivity problems.
3. Ability to decouple user code from the control plane, so problems with user code do not necessarily affect the operation of control plane.
4. Consistency with Discord API reference. For example, when you find [Create Message](https://discord.com/developers/docs/resources/channel#create-message) from the Discord API documentation, you can find the equivalent `create_message` function (lowercase, snake case).
5. High-level API that makes it easy to develop and operate a Discord bot.

## Features

This project is still a work in progress. The followings are high level tasks:

- [x] Discord v10 API support (reconciled in June 2022)
- [x] Gateway connectivity and auto-recovery from connection problems
- [x] System management via control plane
- [x] Event publisher (local channel, file-based, and ZMQ pub/sub)
- [x] High level command/handler API like those in Xh4H Discord.jl
- [ ] Gateway resume (it currently opens a new connection during recovery)
- [ ] Audit log header (required for certain API calls since v10)
- [ ] Slash commands

## History

[Xh4H](https://github.com/Xh4H) and [Chris de Graaf](https://github.com/christopher-dG) previously implemented the [Xh4H/Discord.jl package](https://github.com/Xh4H/Discord.jl), but it was never published in the Julia registry for several reasons.

Chris started a [new Discord.jl project](https://github.com/christopher-dG/Discord.jl) in 2020 to keep things as simple as possible and minimize extra features in order to maximize maintainability as the Discord API changes. It also aims to be easily extensible, so that packages providing extra features can be written on top of it. However, Chris could not find time to continue working on the project.

[@xxxAnn](https://github.com/xxxAnn) forked Xh4H's Discord.jl package late 2021 in an attempt to update the API to the latest version. The project is called [Ekztazy.jl](https://github.com/Humans-of-Julia/Ekztazy.jl).

[Tom](https://github.com/tk3369) forked Chris' project in 2022 in the light of Discord's plan to decommision version 6 of their API. To avoid confusion to Xh4H and Chris' previous implementations, this package has been renamed to Discorder.jl. While this is a fork from Chris' Discord.jl package, there is no plan to upstream changes.
