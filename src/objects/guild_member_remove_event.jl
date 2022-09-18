# https://discord.com/developers/docs/topics/gateway#guild-member-remove
@discord_object struct GuildMemberRemoveEvent
    guild_id::Snowflake
    user::User
end
