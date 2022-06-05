# Discord API doc does not define a type for this so I make one from response body.
# https://discord.com/developers/docs/resources/guild#list-active-guild-threads-response-body
@discord_object struct ActiveGuildThread
    threads::Vector{DiscordChannel}
    members::Vector{ThreadMember}
end
