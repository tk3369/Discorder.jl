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

