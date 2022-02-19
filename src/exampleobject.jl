import DataStructures
import DataFrames
import SummarizedExperiments
export exampleobject

"""
    exampleobject()

Create an example `MultiAssayExperiment` object. 
This is to be used to improve the succinctness of examples and tests.

# Examples
```jldoctest
julia> using MultiAssayExperiments 

julia> x = exampleobject()
MultiAssayExperiment object
  experiments(2): foo bar
  sampledata(2): name disease
  metadata(1): version
```
"""
function exampleobject() 
    foo = SummarizedExperiments.exampleobject(100, 10)
    cd = SummarizedExperiments.coldata(foo)
    cd[!,"name"] = ["foo" * string(i) for i in 1:size(foo)[2]]

    bar = SummarizedExperiments.exampleobject(50, 8);
    cd = SummarizedExperiments.coldata(bar)
    cd[!,"name"] = ["bar" * string(i) for i in 1:size(bar)[2]]

    exp = DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment}("foo" => foo, "bar" => bar);
    
    # Creating some patients.
    disease = ["good", "bad", "good", "bad", "very bad"]
    name = ["Patient" * string(i) for i in 1:5]
    sd = DataFrames.DataFrame(name = name, disease = disease)

    first = repeat(name, inner = 3)[1:size(foo)[2]]
    second = repeat(name, inner = 2)
    second = second[(length(second) - size(bar)[2] + 1):length(second)]

    sm = DataFrames.DataFrame(
        sample = vcat(first, second),
        experiment = vcat(repeat(["foo"], inner=size(foo)[2]), repeat(["bar"], inner=size(bar)[2])),
        colname = vcat(SummarizedExperiments.coldata(foo)[!,"name"], SummarizedExperiments.coldata(bar)[!,"name"])
    )

    metadata = Dict{String,Any}("version" => "0.1.0")
    return MultiAssayExperiment(exp, sd, sm, metadata);
end
