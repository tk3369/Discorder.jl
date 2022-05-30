# https://discord.com/developers/docs/topics/gateway#guild-role-create-guild-role-create-event-fields
@discord_object struct GuildRoleCreateEvent
    guild_id::Snowflake
    role::Role
end
