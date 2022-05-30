# https://discord.com/developers/docs/topics/gateway#guild-members-chunk
@discord_object struct GuildMembersChunkEvent
    guild_id::Snowflake
    members::Vector{GuildMember}
    chunk_index::Int
    chunk_count::Int
    not_found::Vector{Bool}   # I guess it's Bool since doc is unclear
    presences::Vector{PresenceUpdateEvent}
    nonce::String
end
