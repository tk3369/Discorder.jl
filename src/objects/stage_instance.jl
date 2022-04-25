# https://discord.com/developers/docs/resources/stage-instance#stage-instance-object-stage-instance-structure
@discord_object struct StageInstance
    id::Snowflake
    guild_id::Snowflake
    channel_id::Snowflake
    topic::String
    privacy_level::PrivacyLevel.T
    discoverable_disabled::Bool
    guild_scheduled_event_id::Snowflake
end
