struct Timestamp
    dt::ZonedDateTime
end

# supported timestamp formats when parsing from a string
supported_timestamp_formats() = ["yyyy-mm-ddTHH:MM:SS.ssszzzz", "yyyy-mm-ddTHH:MM:SSzzzz"]

# timestamp format when sending output to JSON
json_timestamp_format() = "yyyy-mm-ddTHH:MM:SS.ssszzzz"

Timestamp(s::AbstractString) = Timestamp(parse_zoned_date_time(s))

function parse_zoned_date_time(s::AbstractString)
    s = replace(s, r"(\d\d\d)\d\d\d\+" => s"\1+") # remove microseconds
    waterfall(supported_timestamp_formats()) do fmt
        ZonedDateTime(s, fmt)
    end
end

Base.show(io::IO, s::Timestamp) = print(io, format(s.dt, json_timestamp_format()))
StructTypes.StructType(::Type{Timestamp}) = StructTypes.StringType()
HTTP.escapeuri(s::Timestamp) = escapeuri(s.dt)
