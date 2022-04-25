# https://discord.com/developers/docs/resources/channel#overwrite-object-overwrite-structure
@discord_object struct Overwrite
    id::Snowflake
    type::String
    allow::Int64
    deny::Int64
end
