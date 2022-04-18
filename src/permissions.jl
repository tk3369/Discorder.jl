struct Permissions
    n::UInt64
end

Permissions(s::AbstractString) = Permissions(parse(UInt64, s))

Base.show(io::IO, s::Permissions) = print(io, "0x", string(s.n; base=16))

StructTypes.StructType(::Type{Permissions}) = StructTypes.StringType()
