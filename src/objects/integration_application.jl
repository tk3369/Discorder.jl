# https://discord.com/developers/docs/resources/guild#integration-application-object-integration-application-structure
@discord_object struct IntegrationApplication
    id::Snowflake
    name::String
    icon::String
    description::String
    bot::User
end
