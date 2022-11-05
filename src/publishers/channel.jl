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

function abort!(publisher::ChannelEventPublisher)
    try
        @info "Closing channel" publisher.channel
        close(publisher.channel)
    catch ex
        @warn "Unable to close channel" publisher.channel
    end
    return nothing
end
