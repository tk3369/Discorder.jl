# https://discord.com/developers/docs/resources/channel#embed-object-embed-thumbnail-structure
@discord_object struct EmbedThumbnail
    url::String
    proxy_url::String
    height::Int
    width::Int
end
