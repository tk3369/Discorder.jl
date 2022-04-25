# https://discord.com/developers/docs/resources/invite#invite-stage-instance-object-invite-stage-instance-structure
# This is deprecated according to API reference
@discord_object struct InviteStageInstance
    members::Vector{GuildMember}  # partial
    participant_count::Int
    speaker_count::Int
    topic::String
end
