# https://discord.com/developers/docs/resources/channel#overwrite-object-overwrite-structure
@discord_object struct Overwrite
    id::Snowflake
    type::Int
    allow::String
    deny::String
end
