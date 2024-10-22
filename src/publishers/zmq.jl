struct ZMQPublisher <: AbstractEventPublisher
    port::Int
    socket::ZMQ.Socket
end

function ZMQPublisher(port::Integer)
    socket = ZMQ.Socket(ZMQ.PUB)
    ZMQ.bind(socket, "tcp://*:$port")
    return ZMQPublisher(port, socket)
end

function publish(publisher::ZMQPublisher, event::Event)
    msg = string(event)
    ZMQ.send(publisher.socket, msg)
    @debug "Published ZMQ event" publisher.port msg
    return nothing
end

function abort!(publisher::ZMQPublisher)
    try
        @info "Closing socket" publisher.socket
        close(publisher.socket)
    catch ex
        @warn "Unable to close socket" publisher.socket
    end
    return nothing
end
