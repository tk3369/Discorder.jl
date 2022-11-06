# A hack to make it easier to pass in an array payload.
struct ArrayBody{T}
    xs::T
end

function JSON3.write(
    kw::Pairs{Symbol,ArrayBody{T},Tuple{Symbol},NamedTuple{(:array,),Tuple{ArrayBody{T}}}}
) where {T}
    return JSON3.write(values(kw).array.xs)
end

function api_call(c, method, path, Into=Nothing, params=Dict(); kwargs...)
    @debug "$method $path"

    headers = [
        "Authorization" => auth_header(c),
        "User-Agent" => USER_AGENT,
        "X-RateLimit-Precision" => "millisecond",
    ]

    body, query = if method in (:PATCH, :POST, :PUT)
        if haskey(kwargs, :files)
            kw_dict = Dict(kwargs)
            files = pop!(kw_dict, :files)
            form_dict = Dict{String,Any}("payload_json" => JSON3.write(kw_dict))
            for (idx, file) in enumerate(files)
                push!(form_dict, "files[$idx]" => open(file))
            end
            Form(form_dict), params
        else
            push!(headers, "Content-Type" => "application/json")
            JSON3.write(kwargs), params
        end
    else
        "", kwargs
    end

    url = "$API_BASE/v$API_VERSION$path"
    if check_rate_limits(rate_limiter(c), path) === RATE_LIMIT_SENTINEL
        return RATE_LIMIT_SENTINEL
    end

    resp = request(method, url, headers, body; query=query, status_exception=false)
    rl_result = apply_rate_limits!(rate_limiter(c), resp)
    if rl_result === RATE_LIMIT_RETRY
        return api_call(c, method, path, Into, params; kwargs...)
    elseif rl_result === RATE_LIMIT_SENTINEL
        return RATE_LIMIT_SENTINEL
    end

    if 200 <= resp.status < 300
        return parse_response(resp, Into)
    else
        throw(StatusError(resp.status, resp))
    end
end

parse_response(resp::Response, ::Type{Nothing}) = nothing
function parse_response(resp::Response, Into)
    return if resp.status == 204
        nothing
    elseif header(resp, "Content-Type") == "application/json"
        try_parse_json(resp.body, Into)
    else
        resp.body
    end
end

function try_parse_json(response::Vector{UInt8}, Into)
    str = String(response)
    @debug "Parsing response" str
    try
        return JSON3.read(str, Into)
    catch ex
        @error "Unable to parse response" ex
        println(str)
        rethrow(ex)
    end
end

path_argname(s) = s
path_argname(s::Symbol) = string("<", s === :emoji_id ? :emoji : s, ">")
path_argname(ex::Expr) = path_argname(ex.args[1])

# TODO: Refactor this to be not huge and ugly.
macro route(name, method, path, kwargs...)
    if path isa String
        path = Expr(:string, path)
    end

    # Copy all the interpolations as arguments.
    fun_args = [x isa Expr ? Expr(:kw, x.args...) : x for x in path.args if !(x isa String)]
    # We'll use this later, but construct it now while `path.args` still makes sense.
    doc_path = join(map(path_argname, path.args))

    # Update the string interpolation arguments to URI-encode them, among some other hacks.
    for (i, arg) in enumerate(path.args)
        done = false
        if !(arg isa String)
            arg = if arg isa Expr && arg.head === :(=)
                k, v = arg.args
                if v === :nothing && i == lastindex(path.args)
                    # When the argument is omitted, remove the trailing slash.
                    done = true
                    path.args[i - 1] = path.args[i - 1][1:(end - 1)]
                    insert!(path.args, i, :($k === nothing ? "" : "/"))
                    i += 1
                    :($k === nothing ? "" : $k)
                else
                    # Remove the default value from the interpolation.
                    k
                end
            elseif arg === :emoji_id
                # Most endpoints that accept emojis use the name,
                # so escapeuri is implemented to encode the name.
                # For the few endpoints that require the ID, this special case exists.
                fun_args[findfirst(==(:emoji_id), fun_args)] = :emoji
                :(emoji isa Emoji ? emoji.id : emoji)
            else
                arg
            end
            path.args[i] = :(escapeuri($arg))
        end
        done && break
    end

    fun = :($name(client, $(fun_args...)) = api_call(client, $(QuoteNode(method)), $path))
    pushfirst!(fun.args[2].args, __source__)

    sig_args = fun.args[1].args
    call_args = fun.args[2].args[end].args
    insert!(sig_args, 2, Expr(:parameters))
    insert!(call_args, 2, Expr(:parameters))
    sig_kws = sig_args[2].args
    call_kws = call_args[2].args
    Into = :Nothing
    for ex in kwargs
        if ex === :kwargs
            # Add trailing keywords that go into the query parameters or body.
            push!(sig_kws, :(kwargs...))
            push!(call_kws, :(kwargs...))
        elseif ex isa Expr && ex.head === :(=)
            k, v = ex.args
            if k === :array
                # Pass one specific keyword as an array body.
                pushfirst!(sig_kws, v)
                pushfirst!(call_kws, Expr(:kw, :array, :(ArrayBody($v))))
            elseif k === :query
                # Add query parameters to a request that uses its keywords for the body.
                tuples = [Expr(:tuple, QuoteNode(t.args[1]), t.args[1]) for t in v.args]
                push!(call_args, Expr(:tuple, tuples...))
                for t in v.args
                    pushfirst!(sig_kws, Expr(:kw, t.args...))
                end
            end
        else
            Into = ex
        end
    end
    insert!(call_args, 6, Into)
    isempty(sig_kws) && deleteat!(sig_args, 2)
    isempty(call_kws) && deleteat!(call_args, 2)

    doc_call = replace(string(Expr(:call, sig_args...)), " = " => "=")
    doc = """
        $doc_call -> $Into

    Make a $method request to `$doc_path`.
    See [the Discord API documentation](https://discord.com/developers/docs/resources/$(RESOURCE[]))
    for more information.
    """

    block = quote
        export $name
        $fun
        @doc $doc $name
    end
    return esc(block)
end

const HasID = Union{Guild,DiscordChannel,User,Message,Overwrite,Role,Webhook}
HTTP.escapeuri(x::HasID) = string(x.id)
HTTP.escapeuri(e::Emoji) = escapeuri(e.name)
HTTP.escapeuri(i::Invite) = escapeuri(i.code)

const RESOURCE = Ref{String}()

# TODO Application

RESOURCE[] = "audit-log"
@route get_guild_audit_log GET "/guilds/$guild_id/audit-logs" AuditLog kwargs

RESOURCE[] = "channel"
@route get_channel GET "/channels/$channel_id" DiscordChannel kwargs
@route modify_channel PATCH "/channels/$channel_id" DiscordChannel kwargs
@route delete_channel DELETE "/channels/$channel_id" DiscordChannel
@route get_channel_messages GET "/channels/$channel_id/messages" Vector{Message} kwargs
@route get_channel_message GET "/channels/$channel_id/messages/$message_id" Message
@route create_message POST "/channels/$channel_id/messages" Message kwargs
@route crosspost_message POST "/channels/$channel_id/messages/$message_id/crosspost" Message
@route create_reaction PUT "/channels/$channel_id/messages/$message_id/reactions/$emoji/@me"
@route delete_own_reaction DELETE "/channels/$channel_id/messages/$message_id/reactions/$emoji/@me"
@route delete_user_reaction DELETE "/channels/$channel_id/messages/$message_id/reactions/$emoji/$user_id"
@route get_reactions GET "/channels/$channel_id/messages/$message_id/reactions/$emoji" Vector{
    User
} kwargs
@route delete_all_reactions DELETE "/channels/$channel_id/messages/$message_id/reactions"
@route delete_all_reactions_for_emoji DELETE "/channels/$channel_id/messages/$message_id/reactions/$emoji"
@route edit_message PATCH "/channels/$channel_id/messages/$message_id" Message kwargs
@route delete_message DELETE "/channels/$channel_id/messages/$message_id"
@route bulk_delete_messages POST "/channels/$channel_id/messages/bulk-delete" kwargs
@route edit_channel_permissions PUT "/channels/$channel_id/permissions/$overwrite" kwargs
@route get_channel_invites GET "/channels/$channel_id/invites" Vector{Invite} kwargs
@route create_channel_invite POST "/channels/$channel_id/invites" Invite kwargs
@route delete_channel_permission DELETE "/channels/$channel_id/permissions/$overwrite"
@route follow_news_channel POST "/channels/$channel_id/followers" FollowedChannel kwargs
@route trigger_typing_indicator POST "/channels/$channel_id/typing"
@route get_pinned_messages GET "/channels/$channel_id/pins" Vector{Message}
@route pin_message PUT "/channels/$channel_id/pins/$message_id"
@route unpin_message DELETE "/channels/$channel_id/pins/$message_id"
@route add_group_dm_recipient PUT "/channels/$channel_id/recipients/$user_id" kwargs
@route remove_group_dm_recipient DELETE "/channels/$channel_id/recipients/$user_id"
@route start_thread_from_message POST "/channels/$channel_id/messages/$message_id/threads" DiscordChannel kwargs
@route start_thread_without_message POST "/channels/$channel_id/threads" DiscordChannel kwargs
@route join_thread PUT "/channels/$channel_id/thread-members/@me"
@route add_thread_member PUT "/channels/$channel_id/thread-members/$user_id"
@route leave_thread DELETE "/channels/$channel_id/thread-members/@me"
@route remove_thread_member DELETE "/channels/$channel_id/thread-members/$user_id"
@route get_thread_member GET "/channels/$channel_id/thread-members/$user_id" ThreadMember
@route list_thread_members GET "/channels/$channel_id/thread-members" Vector{ThreadMember}
@route list_public_archived_threads GET "/channels/$channel_id/threads/archived/public" ArchivedThread kwargs
@route list_private_archived_threads GET "/channels/$channel_id/threads/archived/private" ArchivedThread kwargs
@route list_joined_private_archived_threads GET "/channels/$channel_id/users/@me/threads/archived/private" ArchivedThread kwargs

RESOURCE[] = "emoji"
@route list_guild_emojis GET "/guilds/$guild_id/emojis" Vector{Emoji}
@route get_guild_emoji GET "/guilds/$guild_id/emojis/$emoji_id" Emoji
@route create_guild_emoji POST "/guilds/$guild_id/emojis" Emoji kwargs
@route modify_guild_emoji PATCH "/guilds/$guild_id/emojis/$emoji_id" Emoji kwargs
@route delete_guild_emoji DELETE "/guilds/$guild_id/emojis/$emoji_id"

RESOURCE[] = "guild"
@route create_guild POST "/guilds" Guild kwargs
@route get_guild GET "/guilds/$guild_id" Guild kwargs
@route get_guild_preview GET "/guilds/$guild_id/preview" Guild
@route modify_guild PATCH "/guilds/$guild_id" Guild kwargs
@route delete_guild DELETE "/guilds/$guild_id"
@route get_guild_channels GET "/guilds/$guild_id/channels" Vector{DiscordChannel}
@route create_guild_channel POST "/guilds/$guild_id/channels" DiscordChannel kwargs
@route modify_guild_channel_positions PATCH "/guilds/$guild_id/channels" array = positions
@route list_active_guild_threads GET "/guilds/$guild_id/threads/active"
@route get_guild_member GET "/guilds/$guild_id/members/$user_id" GuildMember
@route list_guild_members GET "/guilds/$guild_id/members" Vector{GuildMember} kwargs
@route search_guild_members GET "/guilds/$guild_id/members/search" Vector{GuildMember} kwargs
@route add_guild_member PUT "/guilds/$guild_id/members/$user_id" GuildMember kwargs
@route modify_guild_member PATCH "/guilds/$guild_id/members/$user_id" kwargs
@route modify_current_member PATCH "/guilds/$guild_id/members/@me" kwargs
@route modify_current_user_nick PATCH "/guilds/$guild_id/members/@me/nick" UserNickChange kwargs
@route add_guild_member_role PUT "/guilds/$guild_id/members/$user_id/roles/$role_id"
@route remove_guild_member_role DELETE "/guilds/$guild_id/members/$user_id/roles/$role_id"
@route remove_guild_member DELETE "/guilds/$guild_id/members/$user_id"
@route get_guild_bans GET "/guilds/$guild_id/bans" Vector{Guild}
@route get_guild_ban GET "/guilds/$guild_id/bans/$user_id" Ban
@route create_guild_ban PUT "/guilds/$guild_id/bans/$user_id" kwargs
@route remove_guild_ban DELETE "/guilds/$guild_id/bans/$user_id"
@route get_guild_roles GET "/guilds/$guild_id/roles" Vector{Role}
@route create_guild_role POST "/guilds/$guild_id/roles" Role kwargs
@route modify_guild_role_positions PATCH "/guilds/$guild_id/roles" Vector{Role} array =
    positions
@route modify_guild_role PATCH "/guilds/$guild_id/roles/$role_id" Role kwargs
@route delete_guild_role DELETE "/guilds/$guild_id/roles/$role_id"
@route get_guild_prune_count GET "/guilds/$guild_id/prune" PruneCount kwargs
@route begin_guild_prune POST "/guilds/$guild_id/prune" PruneCount kwargs
@route get_guild_voice_regions GET "/guilds/$guild_id/regions" Vector{VoiceRegion}
@route get_guild_invites GET "/guilds/$guild_id/invites" Vector{Invite}
@route get_guild_integrations GET "/guilds/$guild_id/integrations" Vector{Integration}
@route delete_guild_integration DELETE "/guilds/$guild_id/integrations/$integration_id"
@route get_guild_widget_settings GET "/guilds/$guild_id/widget" GuildWidgetSettings
@route modify_guild_widget PATCH "/guilds/$guild_id/widget" GuildWidget kwargs
@route get_guild_widget GET "/guilds/$guild_id/widget.json" GuildWidget
@route get_guild_vanity_url GET "/guilds/$guild_id/vanity-url" Invite
@route get_guild_widget_image GET "/guilds/$guild_id/widget.png" String
@route get_guild_welcome_screen GET "/guilds/$guild_id/welcome-screen" WelcomeScreen kwargs
@route modify_guild_welcome_screen PATCH "/guilds/$guild_id/welcome-screen" WelcomeScreen kwargs
@route modify_current_user_voice_state PATCH "/guilds/$guild_id/voice-states/@me" kwargs
@route modify_user_voice_state PATCH "/guilds/$guild_id/voice-states/$user_id" kwargs

RESOURCE[] = "guild-scheduled-event"
@route list_guild_scheduled_events GET "/guilds/$guild_id/scheduled-events" Vector{
    GuildScheduledEvent
} kwargs
@route create_guild_scheduled_event POST "/guilds/$guild_id/scheduled-events" GuildScheduledEvent kwargs
@route get_guild_scheduled_event GET "/guilds/$guild_id/scheduled-events/$guild_scheduled_event_id" GuildScheduledEvent kwargs
@route modify_guild_scheduled_event PATCH "/guilds/$guild_id/scheduled-events/$guild_scheduled_event_id" GuildScheduledEvent kwargs
@route delete_guild_scheduled_event DELETE "/guilds/$guild_id/scheduled-events/$guild_scheduled_event_id"
@route get_guild_scheduled_event_users GET "/guilds/$guild_id/scheduled-events/$guild_scheduled_event_id/users" Vector{
    GuildScheduledEventUser
} kwargs

RESOURCE[] = "guild-template"
@route get_guild_template GET "/guilds/templates/$template_code" GuildTemplate
@route create_guild_from_guild_template POST "/guilds/templates/$template_code" Guild kwargs
@route get_guild_templates GET "/guilds/$guild_id/templates" Vector{GuildTemplate}
@route create_guild_template POST "/guilds/$guild_id/templates" GuildTemplate kwargs
@route sync_guild_template PUT "/guilds/$guild_id/templates/$template_code" GuildTemplate
@route modify_guild_template PATCH "/guilds/$guild_id/templates/$template_code" GuildTemplate kwargs
@route delete_guild_template DELETE "/guilds/$guild_id/templates/$template_code" GuildTemplate

RESOURCE[] = "invite"
@route get_invite GET "/invites/$invite_code" Invite kwargs
@route delete_invite DELETE "/invites/$invite_code" Invite

RESOURCE[] = "stage-instance"
@route create_stage_instance POST "/stage-instances" StageInstance kwargs
@route get_stage_instance GET "/stage-instances/{channel.id}" StageInstance
@route modify_stage_instance PATCH "/stage-instances/{channel.id}" StageInstance kwargs
@route delete_stage_instance DELETE "/stage-instances/{channel.id}"

RESOURCE[] = "sticker"
@route get_sticker GET "/stickers/$sticker_id" Sticker
@route list_nitro_sticker_packs GET "/sticker-packs" Vector{Sticker}
@route list_guild_stickers GET "/guilds/$guild_id/stickers" Vector{Sticker}
@route get_guild_sticker GET "/guilds/$guild_id/stickers/$sticker_id" Sticker
@route create_guild_ticker POST "/guilds/$guild_id/stickers" Sticker kwargs
@route modify_guild_sticker PATCH "/guilds/$guild_id/stickers/$sticker_id" Sticker kwargs
@route delete_guild_sticker DELETE "/guilds/$guild_id/stickers/$sticker_id"

RESOURCE[] = "user"
@route get_current_user GET "/users/@me" User
@route get_user GET "/users/$user_id" User
@route modify_current_user PATCH "/users/@me" User kwargs
@route get_current_user_guilds GET "/users/@me/guilds" Vector{Guild} kwargs
@route get_current_user_guild_member GET "/users/@me/guilds/{guild.id}/member" GuildMember
@route leave_guild DELETE "/users/@me/guilds/$guild_id"
@route create_dm POST "/users/@me/channels" DiscordChannel kwargs
@route create_group_dm POST "/users/@me/channels" DiscordChannel kwargs
@route get_user_connections GET "/users/@me/connections" Vector{Connection}

RESOURCE[] = "voice"
@route list_voice_regions GET "/voice/regions" Vector{VoiceRegion}

RESOURCE[] = "webhook"
@route create_webhook POST "/channels/$channel_id/webhooks" Webhook kwargs
@route get_channel_webhooks GET "/channels/$channel_id/webhooks" Vector{Webhook}
@route get_guild_webhooks GET "/guilds/$guild_id/webhooks" Vector{Webhook}
@route get_webhook GET "/webhooks/$webhook_id" Webhook
@route get_webhook_with_token GET "/webhooks/$webhook_id/$webhook_token" Webhook
@route modify_webhook PATCH "/webhooks/$webhook_id" Webhook kwargs
@route modify_webhook_with_token PATCH "/webhooks/$webhook_id/$webhook_token" Webhook kwargs
@route delete_webhook DELETE "/webhooks/$webhook_id" Webhook kwargs
@route delete_webhook_with_token DELETE "/webhooks/$webhook_id/$webhook_token" Webhook kwargs
@route execute_webhook POST "/webhooks/$webhook_id/$webhook_token" Message query = (
    wait=true,
) kwargs
@route execute_github_compatible_webhook POST "/webhooks/$webhook_id/$webhook_token/github" Message query = (
    wait=true,
) kwargs
@route execute_slack_compatible_webhook POST "/webhooks/$webhook_id/$webhook_token/slack" Message query = (
    wait=true,
) kwargs
@route get_webhook_message GET "/webhooks/$webhook_id/$webhook_tokenb/messages/$message_id" Message kwargs
@route edit_webhook_message PATCH "/webhooks/$webhook_id/$webhook_tokenb/messages/$message_id" Message kwargs
@route delete_webhook_message DELETE "/webhooks/$webhook_id/$webhook_tokenb/messages/$message_id" kwargs

RESOURCE[] = "gateway"
@route get_gateway GET "/gateway" Gateway
