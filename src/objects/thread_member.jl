# https://discord.com/developers/docs/resources/channel#thread-member-object-thread-member-structure
@discord_object struct ThreadMember
    id::Snowflake
    user_id::Snowflake
    join_timestamp::Timestamp
    flags::Int
end
