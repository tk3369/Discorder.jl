using Base64: base64encode
using Dates: DateTime
using Test: @test, @testset, @test_nowarn

using BrokenRecord: HTTP, configure!, playback
using JSON3: JSON3

using Discorder: Discorder
const D = Discorder

configure!(;
    path=joinpath(@__DIR__, "fixtures"), ignore_headers=["Authorization", "User-Agent"]
)

@testset "Discorder.jl" begin
    sets = ("snowflake", "objects", "routes")
    @testset "$set" for set in sets
        include("$set.jl")
    end
end
