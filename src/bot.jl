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

function should_trigger(t::CommandTrigger, ev::Event)
    if ev.type == "MESSAGE_CREATE"
        message = ev.data.content
        return !isnothing(match(t.regex, message))
    end
    return false
end

"""
    ReactionAddTrigger

A trigger that is fired when a reaction is added to a message.
"""
struct ReactionAddTrigger <: AbstractTrigger end
should_trigger(t::ReactionAddTrigger, ev::Event) = ev.type == "MESSAGE_REACTION_ADD"

struct Bot
    client::BotClient
    handlers::Dict{AbstractTrigger,Function}
end

Bot() = Bot(BotClient(), Dict{AbstractTrigger,Function}())

function register!(f::Function, bot::Bot, trigger::AbstractTrigger)
    bot.handlers[trigger] = f
    @info "There are $(length(bot.handlers)) handlers"
    return nothing
end

function reset!(bot::Bot)
    empty!(bot.handlers)
end

# Special token to exit bot when a handler returns the token
struct BotExit end

function start(bot::Bot, port::Integer)
    socket = ZMQ.Socket(ZMQ.SUB)
    ZMQ.subscribe(socket, "")
    ZMQ.connect(socket, "tcp://localhost:$port")
    while true
        msg = String(ZMQ.recv(socket))
        event = parse(Event, msg)
        for (trigger, func) in bot.handlers
            if should_trigger(trigger, event)
                result = func(bot.client, event.data)
                result == BotExit() && return
            end
        end
    end
end
