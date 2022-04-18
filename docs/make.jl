using Discorder
using Documenter

makedocs(;
    modules=[Discorder],
    authors="Chris de Graaf <me@cdg.dev>, Tom Kwong <tk3369@gmail.com> and contributors",
    repo="https://github.com/tk3369/Discorder.jl/blob/{commit}{path}#L{line}",
    sitename="Discorder.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/tk3369/Discorder.jl",
)
