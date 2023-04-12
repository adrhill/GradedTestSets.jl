using GradedTestSets
using Documenter

DocMeta.setdocmeta!(GradedTestSets, :DocTestSetup, :(using GradedTestSets); recursive=true)

makedocs(;
    modules=[GradedTestSets],
    authors="Adrian Hill <adrian.hill@mailbox.org>",
    repo="https://github.com/adrhill/GradedTestSets.jl/blob/{commit}{path}#{line}",
    sitename="GradedTestSets.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://adrhill.github.io/GradedTestSets.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/adrhill/GradedTestSets.jl",
    devbranch="main",
)
