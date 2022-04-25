# https://discord.com/developers/docs/resources/invite#invite-object-invite-structure
@discord_object struct Invite
    code::String
    guild::Guild
    channel::DiscordChannel
    inviter::User
    target_type::InviteTargetType.T
    target_user::User
    target_application::Application # partial
    approximate_presence_count::Int
    approximate_member_count::Int
    expires_at::Union{String, DateTime}
    stage_instance::InviteStageInstance
    guild_scheduled_event::GuildScheduledEvent
end
