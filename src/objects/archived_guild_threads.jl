# These APIs do not define a standard type but rather just response body.
# They look consistent for now and so I would just define a type for them.

# https://discord.com/developers/docs/resources/channel#list-public-archived-threads-response-body
# https://discord.com/developers/docs/resources/channel#list-private-archived-threads-response-body
# https://discord.com/developers/docs/resources/channel#list-joined-private-archived-threads-response-body
@discord_object struct ArchivedThread
    threads::Vector{DiscordChannel}
    members::Vector{ThreadMember}
    has_more::Bool
end
