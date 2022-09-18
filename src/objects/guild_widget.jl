# https://discord.com/developers/docs/resources/guild#get-guild-widget-object-get-guild-widget-structure
@discord_object struct GuildWidget
    id::Snowflake
    name::String
    instant_invite::String
    channels::Vector{DiscordChannel}  # partial
    members::Vector{User} # partial
    presence_count::Int
end
