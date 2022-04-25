# https://discord.com/developers/docs/resources/voice#voice-region-object-voice-region-structure
@discord_object struct VoiceRegion
    id::String
    name::String
    optimal::Bool
    deprecated::Bool
    custom::Bool
end
