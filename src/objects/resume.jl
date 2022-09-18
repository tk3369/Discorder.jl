# https://discord.com/developers/docs/topics/gateway#resume-resume-structure
@discord_object struct Resume
    token::String
    session_id::String
    seq::Int
end
