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
    bt = Base.catch_backtrace()
    Base.showerror(stderr, ex, )
end

"""
    get_logger(; debug, filename)

Return a custom logger that write to the specified file. A timestamp is automatically
injected.

# Keyword arguments
- `debug`: turn on debug logging (default = `false`)
- `filename`: name of log file (default = `"Discorder.log"`)
"""
function get_logger(; debug = false, filename = "Discorder.log")
    timestamp_logger(logger) =
        TransformerLogger(logger) do log
            current_time = now(localzone())
            log = merge(log, (; kwargs = (log.kwargs..., :current_time => current_time)))
            return log
        end
    level = debug ? Logging.Debug : Logging.Info
    return timestamp_logger(MinLevelLogger(FileLogger(filename), level))
end