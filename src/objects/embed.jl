# https://discord.com/developers/docs/resources/channel#embed-object-embed-structure
@discord_object struct Embed
    title::String
    type::String
    description::String
    url::String
    timestamp::Timestamp
    color::Int
    footer::EmbedFooter
    image::EmbedImage
    thumbnail::EmbedThumbnail
    video::EmbedVideo
    provider::EmbedProvider
    author::EmbedAuthor
    fields::Vector{EmbedField}
end
