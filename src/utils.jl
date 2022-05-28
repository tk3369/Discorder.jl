"""
    waterfall(f, xs)

Apply function `f` to each element of collection `xs` iteratively and return
the very first application where no exception was thrown. If every application
throws exception then the last exception is re-thrown.
"""
function waterfall(f, xs)
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