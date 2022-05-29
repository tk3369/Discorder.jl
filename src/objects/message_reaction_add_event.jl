# https://discord.com/developers/docs/topics/gateway#message-reaction-add-message-reaction-add-event-fields
@discord_object struct MessageReactionAddEvent
    user_id::Snowflake
    channel_id::Snowflake
    message_id::Snowflake
    guild_id::Snowflake
    member::GuildMember
    emoji::Emoji
end