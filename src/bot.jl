using ZMQ: ZMQ

"""
    AbstractTrigger

A trigger is used to represent data that can be used to determine whether
an event handler should be fired. For example, a regex-based command trigger
may store a `Regex` object that can be used to match messages.
"""
abstract type AbstractTrigger end

"""
    CommandTrigger

A regex-based trigger that matches a message pattern.
"""
struct CommandTrigger <: AbstractTrigger
    regex::Regex
end

"""
Return a vector of arguments that is passed to the user function
when triggered, or `nothing` if the trigger should not be fired.
"""
function should_trigger end

function should_trigger(t::CommandTrigger, ev::Event)
    if ev.type == "MESSAGE_CREATE"
        message = ev.data.content
        result = match(t.regex, message)
        isnothing(result) && return nothing
        return result.captures
    end
    return nothing
end

"""
    ReactionAddTrigger

A trigger that is fired when a reaction is added to a message.
"""
struct ReactionAddTrigger <: AbstractTrigger end

function should_trigger(t::ReactionAddTrigger, ev::Event)
    if ev.type == "MESSAGE_REACTION_ADD"
        return [ev.data.emoji.name]
    end
    return nothing
end

struct Bot
    client::BotClient
    handlers::Dict{AbstractTrigger,Function}
end

Bot() = Bot(BotClient(), Dict{AbstractTrigger,Function}())

function register!(f::Function, bot::Bot, trigger::AbstractTrigger)
    bot.handlers[trigger] = f
    @debug "There are $(length(bot.handlers)) handlers"
    return nothing
end

function reset!(bot::Bot)
    empty!(bot.handlers)
end

# Special token to exit bot when a handler returns the token
struct BotExit end

function start(bot::Bot, port::Integer, host="localhost")
    connection_string = "tcp://$host:$port"
    socket = ZMQ.Socket(ZMQ.SUB)
    ZMQ.subscribe(socket, "")
    ZMQ.connect(socket, connection_string)
    @info "Starting event loop, listening to $connection_string"
    while true
        msg = String(ZMQ.recv(socket))
        event = parse(Event, msg)
        for (trigger, func) in bot.handlers
            trigger_args = should_trigger(trigger, event)
            if !isnothing(trigger_args)
                result = func(bot.client, event.data, trigger_args...)
                result == BotExit() && return
            end
        end
    end
end