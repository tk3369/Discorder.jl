# https://discord.com/developers/docs/resources/guild#integration-object-integration-structure
@discord_object struct Integration
    id::Snowflake
    name::String
    type::String
    enabled::Bool
    syncing::Bool
    role_id::Snowflake
    enable_emoticons::Bool
    expire_behavior::IntegrationExpireBehavior.T
    expire_grace_period::Int
    user::User
    account::IntegrationAccount
    synced_at::Union{String, DateTime}
    subscriber_count::Int
    revoked::Bool
    application::IntegrationApplication
end
