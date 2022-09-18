# https://discord.com/developers/docs/topics/gateway#voice-server-update
@discord_object struct VoiceServerUpdateEvent
    token::String
    guild_id::Snowflake
    endpoint::String
end
