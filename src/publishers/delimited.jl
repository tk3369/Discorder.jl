struct DelimitedFileEventPublisher <: AbstractEventPublisher
    path::String
    delimiter::String
    flush::Bool
    io::IOStream
end

function DelimitedFileEventPublisher(path::String, delimiter="\t", flush=true)
    io = open(path; write=true, create=true, append=true)
    return DelimitedFileEventPublisher(path, delimiter, flush, io)
end

function publish(publisher::DelimitedFileEventPublisher, event::Event)
    record = [event.type, string(event.timestamp), JSON3.write(event.data)]
    println(publisher.io, join(record, publisher.delimiter))
    publisher.flush && flush(publisher.io)
    @debug "Published file event" event.type event.timestamp
    return nothing
end
