# https://discord.com/developers/docs/topics/teams#data-models-team-member-object
@discord_object struct TeamMember
    membership_state::MembershipState.T
    permissions::Vector{String}  # doc says: will always be ["*"]
    team_id::Snowflake
    user::User  # partial
end
