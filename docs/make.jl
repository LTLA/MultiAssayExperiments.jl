using MultiAssayExperiments
using Documenter

makedocs(
    sitename="MultiAssayExperiments.jl",
    modules = [MultiAssayExperiments],
    pages=[
        "Home" => "index.md"
    ]
)

deploydocs(;
    repo="github.com/LTLA/MultiAssayExperiments.jl",
)

