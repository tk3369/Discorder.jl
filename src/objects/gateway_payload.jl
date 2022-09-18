@discord_object struct GatewayPayload
    op::GatewayOpcode.T
    d::Any
    s::Int
    t::String
end
