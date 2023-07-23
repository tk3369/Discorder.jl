using Base64: base64encode
using Dates: DateTime
using Test: @test, @testset, @test_nowarn

using BrokenRecord: HTTP, configure!, playback
using JSON3: JSON3

using Discorder: Discorder
const D = Discorder

# A valid token is required when BrokenRecord fixtures need to be regenerated.
# Do that in your shell rather than messing the code here. In a regular test
# run, a fake token is used as follows.
replay = false
if !haskey(ENV, "DISCORD_BOT_TOKEN")
    ENV["DISCORD_BOT_TOKEN"] = "test123"
    global replay = true
end

configure!(;
    path=joinpath(@__DIR__, "fixtures"), ignore_headers=["Authorization", "User-Agent"]
)

@testset "Discorder.jl" begin
    sets = ("snowflake", "objects", "routes")
    @testset "$set" for set in sets
        include("$set.jl")
    end
end
