# https://discord.com/developers/docs/topics/gateway#typing-start
@discord_object struct TypingStartEvent
    channel_id::Snowflake
    guild_id::Snowflake
    user_id::Snowflake
    timestamp::Int
    member::GuildMember
end
