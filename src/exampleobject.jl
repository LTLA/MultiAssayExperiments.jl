"""
    MultiAssayExperiments.exampleobject()

Create an example `MultiAssayExperiment` object. 
This is to be used to improve the succinctness of examples and tests.

# Examples
```jldoctest
julia> using MultiAssayExperiments 

julia> x = MultiAssayExperiments.exampleobject()
MultiAssayExperiment object
  experiments(2): foo bar
  sampledata(2): name disease
  metadata(1): version
```
"""
function MultiAssayExperiments.exampleobject() 
    foo = exampleobject(100, 10)
    cd = coldata(foo)
    cd[!,"name"] = ["foo" * string(i) for i in 1:size(foo)[2]]

    bar = exampleobject(50, 8);
    cd = coldata(bar)
    cd[!,"name"] = ["bar" * string(i) for i in 1:size(bar)[2]]

    exp = OrderedDict{String, SummarizedExperiment}("foo" => foo, "bar" => bar);
    
    # Creating some patients.
    disease = ["good", "bad", "good", "bad", "very bad"]
    name = ["Patient" * string(i) for i in 1:5]
    sd = DataFrame(name = name, disease = disease)

    first = repeat(name, inner = 3)[1:size(foo)[2]]
    second = repeat(name, inner = 2)
    second = second[(length(second) - size(bar)[2] + 1):length(second)]

    sm = DataFrame(
        sample = vcat(first, second),
        experiment = vcat(repeat(["foo"], inner=size(foo)[2]), repeat(["bar"], inner=size(bar)[2])),
        colname = vcat(coldata(foo)[!,"name"], coldata(bar)[!,"name"])
    )

    metadata = Dict{String,Any}("version" => "0.1.0")
    return MultiAssayExperiment(exp, sd, sm, metadata);
end
