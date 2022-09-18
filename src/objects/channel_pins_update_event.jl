# https://discord.com/developers/docs/topics/gateway#channel-pins-update
@discord_object struct ChannelPinsUpdateEvent
    guild_id::Snowflake
    channel_id::Snowflake
    last_pin_timestamp::Timestamp
end
