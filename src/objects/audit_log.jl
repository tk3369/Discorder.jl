# https://discord.com/developers/docs/resources/audit-log#audit-log-object-audit-log-structure
@discord_object struct AuditLog
    audit_log_entries::Vector{AuditLogEntry}
    guild_scheduled_events::Vector{GuildScheduledEvent}
    integrations::Vector{Integration}
    threads::Vector{DiscordChannel}
    users::Vector{User}
    webhooks::Vector{Webhook}
end
