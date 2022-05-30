# https://discord.com/developers/docs/topics/gateway#guild-scheduled-event-user-remove
@discord_object struct GuildScheduledEventUserRemoveEvent
    guild_scheduled_event_id::Snowflake
    user_id::Snowflake
    guild_id::Snowflake
end
