# https://discord.com/developers/docs/topics/teams#data-models-team-object
@discord_object struct Team
    icon::String
    id::Snowflake
    members::Vector{TeamMember}
    name::String
    owner_user_id::Snowflake
end
