# https://discord.com/developers/docs/topics/gateway#activity-object-activity-secrets
@discord_object struct ActivitySecrets
    match::String
    join::String
    spectate::String
end
