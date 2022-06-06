# https://discord.com/developers/docs/resources/guild-template#guild-template-object-guild-template-structure
@discord_object struct GuildTemplate
    code::String
    name::String
    description::String
    usage_count::Int
    creator_id::Snowflake
    creator::User
    created_at::Timestamp
    updated_at::Timestamp
    source_guild_id::Snowflake
    serialized_source_guild::Guild
    is_dirty::Bool
end
