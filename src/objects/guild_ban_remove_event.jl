# https://discord.com/developers/docs/topics/gateway#guild-ban-remove
@discord_object struct GuildBanRemoveEvent
    guild_id::Snowflake
    user::User
end
