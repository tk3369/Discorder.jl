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
    # TODO this part of constructing event object is hacky
    event_str = JSON3.write(parsed.data)
    event_obj = JSON3.read(event_str, payload_type)
    zoned_dt = parse_zoned_date_time(parsed.timestamp)
    return Event(parsed.type, event_obj, zoned_dt)
end

"""
    AbstractEventPublisher

An interface for publishing gateway events.
"""
abstract type AbstractEventPublisher end

"""
    publish(publisher::AbstractEventPublisher, event::Event)

Publish an event via the provided event publisher.
"""
function publish(publisher::AbstractEventPublisher, event::Event) end
