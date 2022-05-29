# https://discord.com/developers/docs/topics/gateway#message-delete-message-delete-event-fields
@discord_object struct MessageDeleteEvent
    id::Snowflake
    channel_id::Snowflake
    guild_id::Snowflake
end
