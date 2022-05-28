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
    data = Dict{Symbol,Any}()
    for name in propertynames(x)
        val = getproperty(x, name)
        if !ismissing(val)
            data[name] = val
        end
    end
    return JSON3.write(data)
end

json(x::AbstractDiscordObject) = JSON3.write(toDict(x))

function toDict(x::AbstractDiscordObject, data=Dict{Symbol,Any}())
    for name in propertynames(x)
        val = getproperty(x, name)
        if !ismissing(val)
            data[name] = val isa AbstractDiscordObject ? toDict(val) : val
        end
    end
    return data
end

function populate(discord_type, dct::Dict)
    discord_object = discord_type()
    field_names = fieldnames(discord_type)
    field_types = fieldtypes(discord_type)
    type_map = Dict(k => v for (k, v) in zip(field_names, field_types))
    for k in keys(dct)
        ksym = Symbol(k)
        if ksym in field_names
            T = type_map[ksym]
            NT = normalize_discord_object_type(T)
            if length(NT) > 0 && NT[1] <: AbstractVector && (
                eltype(NT[1]) <: Snowflake ||
                eltype(NT[1]) <: AbstractDiscordObject
            )
                ET = eltype(NT[1])
                ar = ET[populate(ET, el) for el in dct[k]]
                # @info "ar" ar
                length(ar) > 0 && setproperty!(discord_object, ksym, ar)
            elseif has_discord_object_type(T)
                DT = extract_discord_object_type(T)
                dct[k] isa Dict || error("Wat: k=$k T=$T DT=$DT")
                val = populate(DT, dct[k])
                setproperty!(discord_object, ksym, val)
            else
                @info "Setting field: $ksym, $(dct[k])"
                setproperty!(discord_object, ksym, dct[k])
            end
        else
            @warn "Cannot handle $ksym"
        end
    end
    return discord_object
end

extract_discord_object_type(T) = typeintersect(T, AbstractDiscordObject)

has_discord_object_type(T) = extract_discord_object_type(T) !== Base.Bottom

function normalize_discord_object_type(CT)
    UT = Base.uniontypes(CT)
    return [T for T in UT
            if T <: AbstractDiscordObject ||
            (T <: AbstractVector && eltype(T) <: AbstractDiscordObject) ||
            T <: Snowflake || (T <: AbstractVector && eltype(T) <: Snowflake)]
end

function traverse(f::Function, T)
    names, types = fieldnames(T), fieldtypes(T)
    for (n, t) in zip(names, types)
        f(n, t)
    end
end

function simplify(T)
    UT = Base.uniontypes(T)
    UT = [T for T in UT if !(T in (A.Null, Missing, Nothing))]
    return length(UT) > 1 ? Union{UT...} : UT[1]
end