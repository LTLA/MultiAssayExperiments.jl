export multifilter, multifilter!

"""
    multifilter!(x; samples = nothing, experiments = nothing, colnames = nothing)

Filters the `MultiAssayExperiment` `x` in place so that it only contains the specified samples, experiments or column names.
This returns a reference to the modified `x`.

See [`filtersamplemap`](@ref) for the accepted values of `samples`, `experiments` and `colnames`.
The behavior of this function is equivalent to calling [`filtersamplemap!`](@ref) followed by [`dropunused!`](@ref).

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = exampleobject();

julia> multifilter!(x; samples = ["Patient2", "Patient3"], experiments = "foo")
MultiAssayExperiment object
  experiments(1): foo
  sampledata(2): name disease
  metadata(1): version
```
"""
function multifilter!(x::MultiAssayExperiment; samples = nothing, experiments = nothing, colnames = nothing)
    filtersamplemap!(x; samples = samples, experiments = experiments, colnames = colnames)
    dropunused!(x; samples = (samples != nothing), experiments = (experiments != nothing), colnames = (colnames != nothing))
    return x
end

"""
    multifilter!(x; samples = nothing, experiments = nothing, colnames = nothing)

Return a new `MultiAssayExperiment` that has been filtered to only the specified samples, experiments or column names.
This makes a copy of `x` and passes it (and any keyword arguments in `kwargs`) to [`multifilter!`](@ref);
see the latter function for more details.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = exampleobject();

julia> multifilter(x; samples = ["Patient2", "Patient3"], experiments = "foo")
MultiAssayExperiment object
  experiments(1): foo
  sampledata(2): name disease
  metadata(1): version
```
"""
function multifilter(x::MultiAssayExperiment; kwargs...) 
    y = copy(x)
    multifilter!(y; kwargs...) 
    return y
end
