# https://discord.com/developers/docs/resources/voice#voice-state-object-voice-state-structure
@discord_object struct VoiceState
    guild_id::Snowflake
    channel_id::Snowflake
    user_id::Snowflake
    member::GuildMember
    session_id::String
    deaf::Bool
    mute::Bool
    self_deaf::Bool
    self_mute::Bool
    self_stream::Bool
    self_video::Bool
    suppress::Bool
    request_to_speak_timestamp::Timestamp
end
