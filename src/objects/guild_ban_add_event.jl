# https://discord.com/developers/docs/topics/gateway#guild-ban-add
@discord_object struct GuildBanAddEvent
    guild_id::Snowflake
    user::User
end
