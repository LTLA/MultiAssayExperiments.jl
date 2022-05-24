"""
    multifilter!(x; samples = nothing, experiments = nothing, colnames = nothing)

Filters the `MultiAssayExperiment` `x` in place so that it only contains the specified samples, experiments or column names.
This returns a reference to the modified `x`.

See [`filtersamplemap`](@ref) for the accepted values of `samples`, `experiments` and `colnames`.
The behavior of this function is equivalent to calling [`filtersamplemap!`](@ref) followed by [`dropunused!`](@ref).
The aspects of `x` that are dropped depend on the arguments:

- Unused samples are dropped from the sample data iff `samples != nothing`.
- Unused experiments are dropped from `experiments(x)` iff `experiments != nothing`.
This may result in some experiments with zero columns after filtering,
but is generally more consistent behavior than experiments disappearing without notice.
- Unused columns are dropped from each experiment if `colnames != nothing`, or if `dropcolnames = true` and `samples != nothing`.
The latter condition provides the expected default behavior, where filtering on the samples is expected to propagate to the corresponding columns of each experiment;
this can be disabled by setting `dropcolnames = false`.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = MultiAssayExperiments.exampleobject();

julia> multifilter!(x; samples = ["Patient2", "Patient3"], experiments = "foo")
MultiAssayExperiment object
  experiments(1): foo
  sampledata(2): name disease
  metadata(1): version

julia> experiment(x)
100x6 SummarizedExperiment
  assays(3): foo bar whee
  rownames: Gene1 Gene2 ... Gene99 Gene100
  rowdata(2): name Type
  colnames: foo4 foo5 ... foo8 foo9
  coldata(3): name Treatment Response
  metadata(1): version
```
"""
function multifilter!(x::MultiAssayExperiment; samples = nothing, experiments = nothing, colnames = nothing, dropcolnames = true)
    filtersamplemap!(x; samples = samples, experiments = experiments, colnames = colnames)

    dropsam = (samples != nothing)
    dropexp = (experiments != nothing)
    dropcol = ((dropsam && dropcolnames) || colnames != nothing)

    dropunused!(x; samples = dropsam, experiments = dropexp, colnames = dropcol)
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

julia> x = MultiAssayExperiments.exampleobject();

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
