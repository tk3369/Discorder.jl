# https://discord.com/developers/docs/topics/gateway#activity-object-activity-structure
# Note that there's another Activity structure defined in the Game SDK.
# We will just ignore that one for now.
@discord_object struct Activity
    name::String
    type::Int
    url::String
    created_at::Int
    timestamps::ActivityTimestamps
    application_id::Snowflake
    details::String
    state::String
    emoji::ActivityEmoji
    party::ActivityParty
    assets::ActivityAssets
    secrets::ActivitySecrets
    instance::Bool
    flags::Int
end
