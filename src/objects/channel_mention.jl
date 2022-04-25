# https://discord.com/developers/docs/resources/channel#channel-mention-object-channel-mention-structure
@discord_object struct ChannelMention
    id::Snowflake
    guild_id::Snowflake
    type::ChannelType.T
    name::String
end
