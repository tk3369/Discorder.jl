# Define a custom type for JSON parsing reason. The specific scenario is when
# a field is specified explicitly as `null` in the JSON string. The default behavior
# of JSON3 parser keeps `missing` for a Union{T,Nothing,Missing} field; but in that
# case, we actually want `nothing` rather than `missing`. Adding a new custom type
# A.Null works around that problem.
module A
struct Null end
end

StructTypes.StructType(::Type{A.Null}) = StructTypes.NullType()
StructTypes.construct(::Type{A.Null}, ::Nothing) = nothing

"""
Convert object to JSON formatted string.
- Fields with `missing` values are excluded.
- Fields with `nothing` values are included as `null`.
"""
function json(x)
    data = Dict{Symbol, Any}()
    for name in propertynames(x)
        val = getproperty(x, name)
        if !ismissing(val)
            data[name] = val
        end
    end
    return JSON3.write(data)
end
