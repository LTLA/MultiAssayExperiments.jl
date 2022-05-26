"""
    filtersamplemap(x; samples = nothing, experiments = nothing, colnames = nothing)

Filter the sample mapping `DataFrame` to the requested samples, experiments and column names.
`x` can either be a `MultiAssayExperiment` or its [`samplemap`](@ref).

If `samples` is `nothing`, it is not used for any filtering.
Otherwise, it may be a vector or set of strings specifying the samples to retain.
A single string may also be supplied.

If `experiments` is `nothing`, it is not used for any filtering.
Otherwise, it may be a vector or set of strings specifying the experiments to retain.
A single string may also be supplied.

If `colnames` is `nothing`, it is not used for any filtering.
Otherwise, it may be a vector or set of strings specifying the columns to retain.
A single string may also be supplied.

A row of the sample mapping is only retained if it passes all supplied filters.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = MultiAssayExperiments.exampleobject();

julia> filtersamplemap(samplemap(x); samples = ["Patient1", "Patient2"])
8×3 DataFrame
 Row │ sample    experiment  colname 
     │ String    String      String  
─────┼───────────────────────────────
   1 │ Patient1  foo         foo1
   2 │ Patient1  foo         foo2
   3 │ Patient1  foo         foo3
   4 │ Patient2  foo         foo4
   5 │ Patient2  foo         foo5
   6 │ Patient2  foo         foo6
   7 │ Patient2  bar         bar1
   8 │ Patient2  bar         bar2

julia> filtersamplemap(samplemap(x); experiments = "foo")
10×3 DataFrame
 Row │ sample    experiment  colname 
     │ String    String      String  
─────┼───────────────────────────────
   1 │ Patient1  foo         foo1
   2 │ Patient1  foo         foo2
   3 │ Patient1  foo         foo3
   4 │ Patient2  foo         foo4
   5 │ Patient2  foo         foo5
   6 │ Patient2  foo         foo6
   7 │ Patient3  foo         foo7
   8 │ Patient3  foo         foo8
   9 │ Patient3  foo         foo9
  10 │ Patient4  foo         foo10
```
"""
function filtersamplemap(x::DataFrame; samples = nothing, experiments = nothing, colnames = nothing)
    sampfun = create_filter_function(samples)
    expfun = create_filter_function(experiments)
    colfun = create_filter_function(colnames)
    return filter(row -> sampfun(row.sample) && expfun(row.experiment) && colfun(row.colname), x) 
end

function create_filter_function(input)
    if input == nothing
        return x -> true
    end

    if isa(input, AbstractString)
        return x -> (x == input)
    end

    if isa(input, AbstractSet{<:AbstractString})
        return x -> (x in input)
    end

    inputset = Set(input)
    return x -> (x in inputset)
end

function filtersamplemap(x::MultiAssayExperiment; kwargs...)
    y = copy(x)
    filtersamplemap!(y; kwargs...)
    return y
end

"""
    filtersamplemap!(x; samples = nothing, experiments = nothing, colnames = nothing)

Modifies `samplemap(x)` in place by filtering based on [`filtersamplemap`](@ref).
A reference to the modified `x` is returned.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = MultiAssayExperiments.exampleobject();

julia> filtersamplemap!(x; samples = ["Patient1", "Patient2"]);

julia> samplemap(x)
8×3 DataFrame
 Row │ sample    experiment  colname 
     │ String    String      String  
─────┼───────────────────────────────
   1 │ Patient1  foo         foo1
   2 │ Patient1  foo         foo2
   3 │ Patient1  foo         foo3
   4 │ Patient2  foo         foo4
   5 │ Patient2  foo         foo5
   6 │ Patient2  foo         foo6
   7 │ Patient2  bar         bar1
   8 │ Patient2  bar         bar2
```
"""
function filtersamplemap!(x::MultiAssayExperiment; samples = nothing, experiments = nothing, colnames = nothing)
    x.samplemap = filtersamplemap(samplemap(x); samples = samples, experiments = experiments, colnames = colnames)
    return x
end

