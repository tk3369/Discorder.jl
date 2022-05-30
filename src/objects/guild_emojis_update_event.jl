# https://discord.com/developers/docs/topics/gateway#guild-emojis-update
@discord_object struct GuildEmojisUpdateEvent
    guild_id::Snowflake
    emojis::Vector{Emoji}
end
