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
    json = JSON3.write(event.data)
    # println("json=$json")
    return join([event.type, string(event.timestamp), json], "\t")
end

function Base.parse(::Type{Event}, s::AbstractString)
    type, timestamp, json = split(s, "\t")
    payload_type = get_event_object_mappings()[type]
    data = JSON3.read(json, payload_type)
    return Event(type, data, parse_zoned_date_time(timestamp))
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
