using MultiAssayExperiments
using Documenter
import SummarizedExperiments
import DataStructures
import DataFrames

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

