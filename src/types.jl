abstract type AbstractDiscordObject end

# Convenient syntax for optional fields
const Optional{T} = Union{T,Nothing}

"""
    Event

A gateway event.
"""
struct Event{S<:AbstractString,T}
    type::S
    data::T
    timestamp::ZonedDateTime
end

Event(type::AbstractString, data::T=nothing) where {T} = Event(type, data, now(localzone()))

Base.show(io::IO, e::Event) = print(io, string(e.timestamp), " ", e.type)

function Base.string(event::Event)
    return JSON3.write(event)
end

function Base.parse(::Type{Event}, json::AbstractString)
    parsed = JSON3.read(json)
    payload_type = get_event_object_mappings()[parsed.type]
    return Event(parsed.type, parsed.data, parse_zoned_date_time(parsed.timestamp))
end

"""
    AbstractEventPublisher

An interface for publishing gateway events.
"""
abstract type AbstractEventPublisher end

"""
    publish(publisher::AbstractEventPublisher, event::Event)

Publish an event via the provided event publisher.

See also: [ChannelEventPublisher](@ref), [ZMQEventPublisher](@ref)
"""
function publish(publisher::AbstractEventPublisher, event::Event) end
