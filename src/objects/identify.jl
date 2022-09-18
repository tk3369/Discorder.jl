@discord_object struct Identify
    token::String
    properties::IdentifyConnectionProperties
    compress::Bool
    large_threshold::Int
    shard::Vector{Int}
    presence::GatewayPresenceUpdate
    intents::Int
end
