"""
Define a Discord resource.
"""
macro discord_object(typedef)
    # Make the type mutable.
    typedef.args[1] = true

    # Make it inherit from a standard abstract type
    struct_name = typedef.args[2]
    typedef.args[2] = Expr(:(<:), struct_name, AbstractDiscordObject)

    # Make all the types nullable/optional with a default value of `missing`.
    fields = typedef.args[3].args
    for (i, field) in enumerate(fields)
        if field isa Expr
            type = field.args[2]
            # TODO Discord API describes nullable, optional, and nullable & optional fields.
            # We might want to consider mapping it more accurately:
            # 1. Nullable: Union{T, A.Null, Nothing}
            # 2. Optional: Union{T, Missing}
            # 3. Nulllable and optional: Union{T, A.Null, Nothing, Missing}
            field.args[2] = :(Union{$type,A.Null,Nothing,Missing})
            fields[i] = :($field = missing)
        end
    end
    typedef_withkw = esc(:(@with_kw $typedef))

    # Enable JSON IO for the type.
    name = esc(struct_name)
    json_methods = quote
        StructTypes.StructType(::Type{$name}) = StructTypes.Mutable()
        JSON3.write(x::$name) = json(x)
    end

    return quote
        export $name
        $typedef_withkw
        $json_methods
    end
end

macro discord_enum(name, block, kwargs...)
    if name isa Expr
        name.head == :(::) || throw(ArgumentError("Bug: enum express must be like <name>::<type>"))
        base_type = name.args[2]
        name = name.args[1]
    else
        base_type = Symbol(Int32)   # default base type for enums
    end

    exp = :(export $(esc(name)))
    enum_name = Expr(:., name, QuoteNode(Symbol("T")))

    extras = Expr(:block)
    for ex in kwargs
        k, v = ex.args
        if v === true
            if k === :or
                or = :(Base.:(|)(a::$(esc(enum_name)), b::$(esc(enum_name))) = Int(a) | Int(b))
                push!(extras.args, or)
            end
        end
    end

    name_sym = Expr(:(::), name, base_type)
    Base.eval(__module__, :(@enumx $name_sym $block))

    return quote
        StructTypes.StructType(::Type{$(esc(enum_name))}) = StructTypes.NumberType()
        StructTypes.numbertype(::Type{$(esc(enum_name))}) = Int
        $exp
        $extras
    end
end
