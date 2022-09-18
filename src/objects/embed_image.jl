# https://discord.com/developers/docs/resources/channel#embed-object-embed-image-structure
@discord_object struct EmbedImage
    url::String
    proxy_url::String
    height::Int
    width::Int
end
