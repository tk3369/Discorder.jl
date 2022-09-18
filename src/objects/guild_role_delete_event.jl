# https://discord.com/developers/docs/topics/gateway#guild-role-delete-guild-role-delete-event-fields
@discord_object struct GuildRoleDeleteEvent
    guild_id::Snowflake
    role_id::Snowflake
end
