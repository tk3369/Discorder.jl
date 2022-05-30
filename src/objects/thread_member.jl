# https://discord.com/developers/docs/resources/channel#thread-member-object-thread-member-structure
@discord_object struct ThreadMember
    id::Snowflake
    user_id::Snowflake
    join_timestamp::Timestamp
    flags::Int
    # https://discord.com/developers/docs/topics/gateway#thread-member-update
    # Additional fields for Thread Member Update event
    guild_id::Snowflake
end
