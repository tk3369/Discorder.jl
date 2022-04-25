# https://discord.com/developers/docs/resources/audit-log#audit-log-change-object-audit-log-change-structure
@discord_object struct AuditLogChange
    new_value::Any
    old_value::Any
    key::String
end
