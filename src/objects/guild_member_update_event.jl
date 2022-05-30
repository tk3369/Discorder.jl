# https://discord.com/developers/docs/topics/gateway#guild-member-update
@discord_object struct GuildMemberUpdateEvent
    guild_id::Snowflake
    roles::Vector{Snowflake}
    user::User
    nick::String
    avatar::String
    joined_at::Timestamp
    premium_since::Timestamp
    deaf::Bool
    mute::Bool
    pending::Bool
    communication_disabled_until::Timestamp
end
