# https://discord.com/developers/docs/topics/gateway#message-reaction-remove-all-message-reaction-remove-all-event-fields
@discord_object struct MessageReactionRemoveAllEvent
    channel_id::Snowflake
    message_id::Snowflake
    guild_id::Snowflake
end