# https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-entry-structure
@discord_object struct AuditLogEntry
    target_id::String
    changes::Vector{AuditLogChange}
    user_id::Snowflake
    id::Snowflake
    action_type::AuditLogEvent.T
    options::OptionalAuditEntryInfo
    reason::String
end
