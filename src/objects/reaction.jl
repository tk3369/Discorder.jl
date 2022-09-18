# https://discord.com/developers/docs/resources/channel#reaction-object-reaction-structure
@discord_object struct Reaction
    count::Int
    me::Bool
    emoji::Emoji  # partial
end
