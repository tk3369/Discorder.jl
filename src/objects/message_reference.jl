# https://discord.com/developers/docs/resources/channel#message-reference-object-message-reference-structure
@discord_object struct MessageReference
    message_id::Snowflake
    channel_id::Snowflake
    guild_id::Snowflake
    fail_if_not_exists::Bool
end
