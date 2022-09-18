# https://discord.com/developers/docs/topics/gateway#activity-object-activity-emoji
@discord_object struct ActivityEmoji
    name::String
    id::Snowflake
    animated::Bool
end
