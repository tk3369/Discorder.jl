# https://discord.com/developers/docs/topics/gateway#activity-object-activity-party
@discord_object struct ActivityParty
    id::String
    size::Vector{Int}   # current_size, max_size
end
