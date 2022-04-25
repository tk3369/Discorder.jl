# https://discord.com/developers/docs/resources/guild#guild-widget-settings-object-guild-widget-settings-structure
@discord_object struct GuildWidgetSettings
    enabled::Bool
    channel_id::Snowflake
end
