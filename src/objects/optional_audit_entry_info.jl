# https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-optional-audit-entry-info
@discord_object struct OptionalAuditEntryInfo
    channel_id::Snowflake
    count::String
    delete_member_days::String
    id::Snowflake
    members_removed::String
    message_id::Snowflake
    role_name::String
    type::String
end
