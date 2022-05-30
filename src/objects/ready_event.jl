# https://discord.com/developers/docs/topics/gateway#ready-ready-event-fields
@discord_object struct ReadyEvent
    v::Int  # gateway version
    user::User
    guilds::Vector{UnavailableGuild}
    session_id::String
    shard::Vector{Int}
    application::Application
end
