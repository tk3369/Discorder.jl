# https://discord.com/developers/docs/resources/sticker#sticker-pack-object
@discord_object struct StickerPack
    id::Snowflake
    stickers::Vector{Sticker}
    name::String
    sku_id::Snowflake
    cover_sticker_id::Snowflake
    description::String
    banner_asset_id::Snowflake
end
