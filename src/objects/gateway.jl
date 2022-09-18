@discord_object struct Gateway
    url::String
    shards::Int
    session_start_limit::SessionStartLimit
end
