@discord_object struct Role
    id::Snowflake
    name::String
    color::Int
    hoist::Bool
    position::Int
    permissions::Permissions
    managed::Bool
    mentionable::Bool
end
