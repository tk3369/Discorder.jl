# https://discord.com/developers/docs/topics/gateway#message-reaction-remove-message-reaction-remove-event-fields
@discord_object struct MessageReactionRemoveEvent
    user_id::Snowflake
    channel_id::Snowflake
    message_id::Snowflake
    guild_id::Snowflake
    emoji::Emoji
end