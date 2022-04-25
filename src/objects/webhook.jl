# https://discord.com/developers/docs/resources/webhook#webhook-object-webhook-structure
@discord_object struct Webhook
    id::Snowflake
    type::WebhookType.T
    guild_id::Snowflake
    channel_id::Snowflake
    user::User
    name::String
    avatar::String
    token::String
    application_id::Snowflake
    source_guild::Guild  # partial
    source_channel::DiscordChannel  # partial
    url::String
end
