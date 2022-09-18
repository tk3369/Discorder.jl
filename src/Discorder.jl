module Discorder

export BotClient, BearerClient

# To operate gateway server
export ZMQPublisher, GatewayTracker
export serve

# To operate a bot
export Bot, BotExit, CommandTrigger, ReactionAddTrigger, register!, reset!, start

using Base.Iterators: Pairs

using Dates:
    DateTime, ISODateTimeFormat, Millisecond, UTC, now, unix2datetime, year, format, Second
using Logging: Logging, with_logger
using TOML: TOML

using EnumX: @enumx
using HTTP: HTTP, Form, Response, StatusError, escapeuri, header, request
using JSON3: JSON3, StructTypes
using LoggingExtras: TransformerLogger, FileLogger, MinLevelLogger
using Parameters: @with_kw
using TimeZones: localzone, ZonedDateTime
using ZMQ: ZMQ

const API_BASE = "https://discord.com/api"
const API_VERSION = 10

# See format at https://discord.com/developers/docs/reference#user-agent
const USER_AGENT = let
    toml = read(joinpath(@__DIR__, "..", "Project.toml"), String)
    package_version = VersionNumber(match(r"version = \"(.*)\"", toml)[1])
    package_url = "https://github.com/tk3369/Discorder.jl"
    julia_version = VERSION
    "DiscordBot ($package_url, $package_version) / Julia $julia_version"
end

include("types.jl")
include("snowflake.jl")
include("permissions.jl")
include("timestamp.jl")
include("utils.jl")
include("json.jl")
include("macros.jl")
include("objects.jl")
include("rate_limiter.jl")
include("clients.jl")
include("routes.jl")
include("constants.jl")
include("gateway.jl")
include("bot.jl")
include("publishers/channel.jl")
include("publishers/delimited.jl")
include("publishers/zmq.jl")

end
