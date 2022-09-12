using ZMQ: ZMQ

export SimpleBot, CommandTrigger, ReactionAddTrigger, register!, play

abstract type AbstractBot end

struct SimpleBot <: AbstractBot
    client::BotClient
    handlers::Vector{Any}
end

SimpleBot() = SimpleBot(BotClient(), Any[])

abstract type AbstractTrigger end

struct CommandTrigger <: AbstractTrigger
    prefix::Char
    regex::Regex  # matches starting 2nd character
end

function should_trigger(t::CommandTrigger, ev::Event)
    if ev.type == "MESSAGE_CREATE"
        message = ev.data.content
        first(message) == t.prefix || return false
        rest = message[nextind(message, 1):end]
        return !isnothing(match(t.regex, rest))
    end
    return false
end

struct ReactionAddTrigger <: AbstractTrigger end
should_trigger(t::ReactionAddTrigger, ev::Event) = ev.type == "MESSAGE_REACTION_ADD"

struct Handler{T<:AbstractTrigger,F<:Function}
    trigger::T
    func::F
end

function register!(f::Function, bot::AbstractBot, trigger::AbstractTrigger)
    return push!(bot.handlers, Handler(trigger, f))
end

function play(bot::AbstractBot; port=6000)
    socket = ZMQ.Socket(ZMQ.SUB)
    ZMQ.subscribe(socket, "")
    ZMQ.connect(socket, "tcp://localhost:$port")
    while true
        msg = String(ZMQ.recv(socket))
        event = parse(Event, msg)
        for handler in bot.handlers
            if should_trigger(handler.trigger, event)
                handler.func(bot.client, event.data)
            end
        end
    end
end
