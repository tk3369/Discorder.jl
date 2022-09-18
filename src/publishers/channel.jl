struct ChannelEventPublisher <: AbstractEventPublisher
    size::Int
    channel::Channel{Event}
end

function ChannelEventPublisher(size::Integer)
    return ChannelEventPublisher(size, Channel{Event}(size))
end

function publish(publisher::ChannelEventPublisher, event::Event)
    put!(publisher.channel, event)
    @debug "Published channel event" event.type event.timestamp
    return nothing
end

