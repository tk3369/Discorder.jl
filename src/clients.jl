struct Token
    token::String
end

Base.show(io::IO, ::Token) = print(io, "<token>")

struct BotClient
    token::Token
    rate_limiter::RateLimiter

    function BotClient(token=get_bot_token(); rate_limiter=RateLimiter())
        return new(Token(token), rate_limiter)
    end
end

struct BearerClient
    token::Token
    rate_limiter::RateLimiter

    BearerClient(token; rate_limiter=RateLimiter()) = new(Token(token), rate_limiter)
end

auth_header(c::BotClient) = "Bot $(c.token.token)"
auth_header(c::BearerClient) = "Bearer $(c.token.token)"

rate_limiter(c::BotClient) = c.rate_limiter
rate_limiter(c::BearerClient) = c.rate_limiter
