# https://discord.com/developers/docs/resources/channel#embed-object-embed-video-structure
@discord_object struct EmbedVideo
    url::String
    proxy_url::String
    height::Int
    width::Int
end
