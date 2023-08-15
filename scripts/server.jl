# A simple Portal server

using Discorder

cfg = ARGS[1]

gw = Ref{GatewayTracker}()
task = @async serve(tracker_ref=gw, config_file_path=cfg)

@info "Starting Portal, please wait..."
while true
    if isassigned(gw) && Discorder.is_operational(gw[])
        break
    end
    sleep(0.5)
end
@info "Portal started successfully."

wait(task)
