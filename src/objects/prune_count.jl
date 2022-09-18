# https://discord.com/developers/docs/resources/guild#get-guild-prune-count
# Note: the API reference only describes the structure (no official fields table)
@discord_object struct PruneCount
    pruned::Int
end
