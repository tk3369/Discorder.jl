# https://discord.com/developers/docs/resources/channel#thread-metadata-object-thread-metadata-structure
@discord_object struct ThreadMetadata
    archived::Bool
    auto_archive_duration::Int
    archive_timestamp::Union{String,DateTime}
    locked::Bool
    invitable::Bool
    create_timestamp::Union{String,DateTime}
end