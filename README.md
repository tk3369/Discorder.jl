# Discorder

[![Discorder](https://img.shields.io/badge/discord-join-7289da.svg)](https://discord.gg/ng9TjYd)

Write [Discord](https://discord.com) bots in [Julia](https://julialang.org).

### Current status

Here is the list of features:
- [x] Discord v10 API support (reconciled in June 2022)
- [x] Gateway connectivity and auto-recovery from connection problems
- [x] System management via control plane
- [x] Event publisher (local channel, file-based, and ZMQ pub/sub)
- [ ] High level command/handler API like those in Xh4H Discord.jl
- [ ] Comprehensive tests for all APIs and gateway events
- [ ] Gateway resume (it currently opens a new connection during recovery)

### History

[Xh4H](https://github.com/Xh4H) and [Chris de Graaf](https://github.com/christopher-dG) previously implemented the [Xh4H/Discord.jl package](https://github.com/Xh4H/Discord.jl), but it was never published in  Julia registry for several reasons.

Chris started a [new Discord.jl project](https://github.com/christopher-dG/Discord.jl) in 2020 to keep things as simple as possible and minimize extra features in order to maximize maintainability as the Discord API changes. It also aims to be easily extensible, so that packages providing extra features can be written on top of it. However, Chris could not find time to continue working on the project.

[Tom](https://github.com/tk3369) forked Chris' project in 2022 in the light of Discord's plan to decommision version 6 of their API. To avoid confusion to Xh4H and Chris' previous implementations, this package has been renamed to Discorder.jl.
