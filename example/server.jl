# From the projects root directory, run `julia --project=. example/server.jl`
# NOTE: Make sure that DISCORD_BOT_TOKEN is already set in the environment.
using Discorder

cfg = "etc/dev.toml"

gw = Ref{GatewayTracker}()
task = @async serve(tracker_ref=gw, config_file_path=cfg)

@info "Gateway server starting, please wait..."
while true
    if isassigned(gw) && Discorder.is_operational(gw[])
        break
    end
    sleep(0.1)
end

wait(task)
