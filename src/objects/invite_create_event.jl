# https://discord.com/developers/docs/topics/gateway#invite-create
@discord_object struct InviteCreateEvent
    channel_id::Snowflake
    code::String
    created_at::Timestamp
    guild_id::Snowflake
    inviter::User
    max_age::Int
    max_uses::Int
    target_type::Int
    target_user::User
    target_application::Application
    temporary::Bool
    uses::Int
end
