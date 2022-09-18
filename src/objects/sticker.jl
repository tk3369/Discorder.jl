# https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-structure
@discord_object struct Sticker
    id::Snowflake
    pack_id::Snowflake
    name::String
    description::String
    tags::String
    asset::String
    type::StickerType.T
    format_type::StickerFormatType.T
    available::Bool
    guild_id::Snowflake
    user::User
    sort_value::Int
end
