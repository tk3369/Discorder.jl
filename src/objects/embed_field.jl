# https://discord.com/developers/docs/resources/channel#embed-object-embed-field-structure
@discord_object struct EmbedField
    name::String
    value::String
    inline::Bool
end
