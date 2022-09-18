# https://discord.com/developers/docs/topics/gateway#integration-delete
@discord_object struct IntegrationDeleteEvent
    id::Snowflake
    guild_id::Snowflake
    application_id::Snowflake
end
