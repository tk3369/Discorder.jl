# https://discord.com/developers/docs/topics/gateway#update-presence-gateway-presence-update-structure
@discord_object struct GatewayPresenceUpdate
    since::Int
    activities::Vector{Activity}
end
