# https://discord.com/developers/docs/topics/gateway#thread-list-sync
@discord_object struct ThreadListSyncEvent
    guild_id::Snowflake
    channel_ids::Vector{Snowflake}
    threads::Vector{Channel}
    members::Vector{ThreadMember}
end
