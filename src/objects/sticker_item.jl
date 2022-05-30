# https://discord.com/developers/docs/resources/sticker#sticker-item-object
@discord_object struct StickerItem
    id::Snowflake
    name::String
    format_type::StickerFormatType.T
end
