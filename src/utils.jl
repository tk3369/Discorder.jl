"""
    get_bot_token()

Get the bot token from enviornment variable `DISCORD_BOT_TOKEN`.
"""
function get_bot_token()
    token = get(ENV, "DISCORD_BOT_TOKEN", "")
    isempty(token) && error("Please define DISCORD_BOT_TOKEN environemnt variable.")
    return token
end

"""
    waterfall(f, xs)

Apply function `f` to each element of collection `xs` iteratively and return
the very first application where no exception was thrown. If every application
throws exception then the last exception is re-thrown.
"""
function waterfall(f::Function, xs)
    local err
    for x in xs
        try
            y = f(x)
            return y
        catch ex
            err = ex
        end
    end
    throw(err)
end

"""
    show_error(ex::Exception)

Display an error in the log with backtrace. This is usefulf for
debugging purpose.
"""
function show_error(ex::Exception)
    for (i, frame) in enumerate(stacktrace(catch_backtrace()))
        @error "Backtrace $i: $(frame.func) at $(frame.file):$(frame.line)"
    end
    return nothing
end

"""
    get_logger(filename; debug::Bool)

Return a custom logger that write to the specified log file. A timestamp is automatically
injected.

# Arguments
- `file_path`: path of log file

# Keyword arguments
- `debug`: turn on debug logging (default = `false`)
"""
function get_logger(file_path; debug=false)
    function timestamp_logger(logger)
        TransformerLogger(logger) do log
            current_time = now(localzone())
            log = merge(log, (; kwargs=(log.kwargs..., :current_time => current_time)))
            return log
        end
    end
    level = debug ? Logging.Debug : Logging.Info
    return timestamp_logger(MinLevelLogger(FileLogger(file_path), level))
end

"""
    sanitize(s::AbstractString)

Remove sensitive information such as Bot token.
"""
function sanitize(s::AbstractString)
    return replace(s, r"(\"token\":\")[^\"]+(\")" => s"\1xxxxxxxx\2")
end
