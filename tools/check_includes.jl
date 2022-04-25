# Check if all objects are included in the package.
#
# Just run it from the main directory:
#     julia> include("tools/check_includes.jl")

# This is how objects are included in objects.jl
#     include(joinpath("objects", "enums.jl"))
include_statements = filter(readlines("src/objects.jl")) do line
    matched = match(r"include.*objects.*jl", line)
    !isnothing(matched)
end

already_included_files = map(include_statements) do s
    eval(Meta.parse(replace(s, r"include\((.*)\)" => s"\1") ))
end

sources = replace.(readdir("src/objects"; join=true), "src/" => "")

missing_includes = [s for s in sources if s ∉ already_included_files]

if isempty(missing_includes)
    println("Everything looks good! No worries.")
else
    println("""
        The following files are defined in the src/objects directory but they
        haven't not been included in the src/objects.jl file.
    """)
    foreach(println, missing_includes)
end
