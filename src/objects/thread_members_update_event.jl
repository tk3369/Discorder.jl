# https://discord.com/developers/docs/topics/gateway#thread-members-update
@discord_object struct ThreadMembersUpdateEvent
    id::Snowflake
    guild_id::Snowflake
    member_count::Int
    added_members::Vector{ThreadMember}
    removed_member_ids::Vector{Snowflake}
end
