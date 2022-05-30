# https://discord.com/developers/docs/topics/gateway#invite-delete
@discord_object struct InviteDeleteEvent
    channel_id::Snowflake
    guild_id::Snowflake
    code::String
end
