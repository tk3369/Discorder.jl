using ZMQ: ZMQ

abstract type AbstractBot end

struct SimpleBot <: AbstractBot
    client::BotClient
    handlers::Vector{Any}
end

SimpleBot() = SimpleBot(BotClient(), Any[])

abstract type AbstractTrigger end

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

struct ReactionAddTrigger <: AbstractTrigger end
should_trigger(t::ReactionAddTrigger, ev::Event) = ev.type == "MESSAGE_REACTION_ADD"

struct Handler{T<:AbstractTrigger,F<:Function}
    trigger::T
    func::F
end

function register!(f::Function, bot::AbstractBot, trigger::AbstractTrigger)
    return push!(bot.handlers, Handler(trigger, f))
end

function start(bot::AbstractBot, port::Integer)
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
