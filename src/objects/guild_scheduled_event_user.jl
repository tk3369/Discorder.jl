# https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-user-object
@discord_object struct GuildScheduledEventUser
    guild_scheduled_event_id::Snowflake
    user::User
    member::GuildMember
end
