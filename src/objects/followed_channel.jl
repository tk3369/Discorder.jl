# https://discord.com/developers/docs/resources/channel#followed-channel-object-followed-channel-structure
@discord_object struct FollowedChannel
    channel_id::Snowflake
    webhook_id::Snowflake
end
