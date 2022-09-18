# https://discord.com/developers/docs/topics/gateway#guild-role-update-guild-role-update-event-fields
@discord_object struct GuildRoleUpdateEvent
    guild_id::Snowflake
    role::Role
end
