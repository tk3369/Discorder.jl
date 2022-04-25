# https://discord.com/developers/docs/resources/channel#attachment-object-attachment-structure
@discord_object struct Attachment
    id::Snowflake
    filename::String
    description::String
    content_type::String
    size::Int
    url::String
    proxy_url::String
    height::Int
    width::Int
    ephemeral::Bool
end
