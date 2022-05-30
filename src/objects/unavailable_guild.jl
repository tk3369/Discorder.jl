# https://discord.com/developers/docs/resources/guild#unavailable-guild-object
@discord_object struct UnavailableGuild
    id::Snowflake
    unavailable::Bool
end
