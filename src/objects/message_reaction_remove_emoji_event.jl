# https://discord.com/developers/docs/topics/gateway#message-reaction-remove-emoji-message-reaction-remove-emoji-event-fields
@discord_object struct MessageReactionRemoveEmojiEvent
    channel_id::Snowflake
    guild_id::Snowflake
    message_id::Snowflake
    emoji::Emoji
end