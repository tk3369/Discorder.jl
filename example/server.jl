# NOTE: Make sure that DISCORD_BOT_TOKEN is already set in the environment.
using Discorder

port = 6000
cfg = "etc/dev.toml"

gw = Ref{GatewayTracker}()
task = @async serve(tracker_ref=gw, config_file_path=cfg, publisher=ZMQPublisher(port))

@info "Gateway server starting, please wait..."
while true
    if isassigned(gw) && Discorder.is_operational(gw[])
        @info "Gateway server started" cfg port
        break
    end
    sleep(0.1)
end

wait(task)
