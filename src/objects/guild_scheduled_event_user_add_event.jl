# https://discord.com/developers/docs/topics/gateway#guild-scheduled-event-user-Add
@discord_object struct GuildScheduledEventUserAddEvent
    guild_scheduled_event_id::Snowflake
    user_id::Snowflake
    guild_id::Snowflake
end
