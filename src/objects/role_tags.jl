# https://discord.com/developers/docs/topics/permissions#role-object-role-tags-structure
@discord_object struct RoleTags
    bot_id::Snowflake
    integration_id::Snowflake
    premium_subscriber::Bool  # type was missing in doc, assuming Bool
end
