# https://discord.com/developers/docs/game-sdk/activities#data-models-activity-struct
@discord_object struct Activity
    application_id::Int
    name::String
    state::String
    details::String
    timestamps::ActivityTimestamps
    assets::ActivityAssets
    party::ActivityParty
    secrets::ActivitySecrets
    instance::Bool
end
