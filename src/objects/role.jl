# https://discord.com/developers/docs/topics/permissions#role-object-role-structure
@discord_object struct Role
    id::Snowflake
    name::String
    color::Int
    hoist::Bool
    icon::String
    unicode_emoji::String
    position::Int
    permissions::Permissions
    managed::Bool
    mentionable::Bool
    tags::RoleTags
end
