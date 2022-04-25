# https://discord.com/developers/docs/resources/guild#guild-member-object-guild-member-structure
@discord_object struct GuildMember
    user::User
    nick::String
    avatar::String
    roles::Vector{Snowflake}
    joined_at::Union{String, DateTime}
    premium_since::Union{String, DateTime}
    deaf::Bool
    mute::Bool
    pending::Bool
    permissions::Permissions
    communication_disabled_until::Union{String, DateTime}
end
