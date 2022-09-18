# https://discord.com/developers/docs/topics/gateway#guild-stickers-update
@discord_object struct GuildStickersUpdateEvent
    guild_id::Snowflake
    stickers::Vector{Sticker}
end
