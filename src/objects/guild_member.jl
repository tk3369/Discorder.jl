# https://discord.com/developers/docs/resources/guild#guild-member-object-guild-member-structure
@discord_object struct GuildMember
    user::User
    nick::String
    avatar::String
    roles::Vector{Snowflake}
    joined_at::Timestamp
    premium_since::Timestamp
    deaf::Bool
    mute::Bool
    pending::Bool
    permissions::Permissions
    communication_disabled_until::Timestamp
    # https://discord.com/developers/docs/topics/gateway#guild-member-add
    # Additional fields for Guild Member Add event
    guild_id::Snowflake
end
