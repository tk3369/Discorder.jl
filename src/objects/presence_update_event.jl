# https://discord.com/developers/docs/topics/gateway#presence-update-presence-update-event-fields
@discord_object struct PresenceUpdateEvent
    user::User
    guild_id::Snowflake
    status::String
    activities::Vector{Activity}
    client_status::ClientStatus
end
