# https://discord.com/developers/docs/game-sdk/activities#data-models-activitysecrets-struct
@discord_object struct ActivitySecrets
    match::String
    join::String
    spectate::String
end
