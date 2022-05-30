# https://discord.com/developers/docs/interactions/receiving-and-responding#message-interaction-object
@discord_object struct MessageInteraction
    id::Snowflake
    type::InteractionType.T
    name::String
    user::User
    member::GuildMember
end
