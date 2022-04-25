# https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-structure
@discord_object struct GuildScheduledEvent
    id::Snowflake
    guild_id::Snowflake
    channel_id::Snowflake
    creator_id::Snowflake
    name::String
    description::String
    scheduled_start_time::Union{String,DateTime}
    scheduled_end_time::Union{String,DateTime}
    privacy_level::PrivacyLevel.T
    status::GuildScheduledEventStatus.T
    entity_type::GuildScheduledEventEntityType.T
    entity_id::Snowflake
    entity_metadata::GuildScheduledEventEntityMetadata
    creator::User
    user_count::Int
    image::String
end
