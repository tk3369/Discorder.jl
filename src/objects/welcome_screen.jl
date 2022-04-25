# https://discord.com/developers/docs/resources/guild#welcome-screen-object-welcome-screen-structure
@discord_object struct WelcomeScreen
    description::String
    welcome_channels::Vector{WelcomeScreenChannel}
end
