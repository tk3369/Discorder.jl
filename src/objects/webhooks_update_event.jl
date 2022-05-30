# https://discord.com/developers/docs/topics/gateway#webhooks-update
@discord_object struct WebhooksUpdateEvent
    guild_id::Snowflake
    channel_id::Snowflake
end
