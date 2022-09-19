using Discorder
using Documenter

makedocs(;
    modules=[Discorder],
    authors="Chris de Graaf <me@cdg.dev>, Tom Kwong <tk3369@gmail.com> and contributors",
    repo="https://github.com/tk3369/Discorder.jl/blob/{commit}{path}#L{line}",
    sitename="Discorder.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[]
    ),
    pages=[
        "User guide" => "index.md",
        "Reference" => "api.md",
        "Developer Docs" => [
            "Dev Guide" => "dev_guide.md",
            "Control Plane Design" => "control_plane.md",
            "Ideas" => "ideas.md",
        ],
    ]
)

deploydocs(;
    repo="github.com/tk3369/Discorder.jl"
)
