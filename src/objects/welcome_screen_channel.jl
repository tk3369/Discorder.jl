# https://discord.com/developers/docs/resources/guild#welcome-screen-object-welcome-screen-channel-structure
@discord_object struct WelcomeScreenChannel
    channel_id::Snowflake
    description::String
    emoji_id::Snowflake
    emoji_name::String
end
