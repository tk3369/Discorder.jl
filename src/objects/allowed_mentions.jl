# https://discord.com/developers/docs/resources/channel#allowed-mentions-object-allowed-mentions-structure
@discord_object struct AlowedMentions
    parse::Vector{String}
    roles::Vector{Snowflake}
    users::Vector{Snowflake}
    replied_user::Bool
end
