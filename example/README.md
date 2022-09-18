# Examples

First, make sure that `DISCORD_BOT_TOKEN` environment variable is set.

Start the gateway server. The log file can be found in Discorder.log.
```
julia --project=. example/server.jl
```

The other example files are bot components. You can simply run them as such:
```
julia --project=. example/echo.jl
julia --project=. example/reaction.jl
```
