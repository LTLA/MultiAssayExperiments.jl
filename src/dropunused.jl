"""
    dropunused!(x; samples = true, experiments = true, colnames = true, mapping = true)

Drop unused samples, experiments and/or column names from the `MultiAssayExperiment` `x`.
A reference to the modified `x` is returned.

If `samples = true`, `sampledata(x)` is filtered to only retain samples that are present in the sample mapping.

If `experiments = true`, `experiments(x)` is filtered to only retain experiments that are present in the sample mapping.

If `colnames = true`, each entry of `experiments(x)` is filtered to only retain column names that are present in the sample mapping for that experiment.

If `mapping = true`, the sample mapping is filtered to remove rows that contain samples, experiments or column names that do not exist in `x`.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = MultiAssayExperiments.exampleobject();

julia> filtersamplemap!(x; experiments = "bar"); # Only keeping experiment 'bar'

julia> dropunused!(x) # We see that 'foo' is dropped
MultiAssayExperiment object
  experiments(1): bar
  sampledata(2): name disease
  metadata(1): version
```
"""
function dropunused!(x::MultiAssayExperiment; samples = true, experiments = true, colnames = true, mapping = true)
    sm = samplemap(x)

    # Filtering the sample mapping first.
    if mapping
        sampset = Set(sm[!,"sample"])
        allcolnames = Dict{AbstractString,Set{<:String}}()
        for (k, v) in x.experiments
            allcolnames[k] = Set(coldata(v)[!,"name"])
        end

        filterfun = function(row)
            return (
                row.sample in sampset && 
                haskey(allcolnames, row.experiment) &&
                row.colname in allcolnames[row.experiment]
            )
        end
        sm = DataFrames.filter(filterfun, sm)
        x.samplemap = sm
    end

    # Applying filters on the samples.
    if samples
        sampset = Set(sm[!,"sample"])
        x.sampledata = DataFrames.filter(row -> row.name in sampset, sampledata(x))
    end

    # Applying filters on the experiments.
    ecopy = nothing
    if experiments
        expset = Set(sm[!,"experiment"])
        ecopy = copy(x.experiments) # making a copy so that we can use this function on a shallow copy.
        for e in keys(x.experiments)
            if !(e in expset)
                delete!(ecopy, e)
            end
        end
        x.experiments = ecopy
    end

    # Applying filters on the column names.
    if colnames
        valid_colnames = Dict{AbstractString,Set{<:AbstractString}}()
        for row in eachrow(sm)
            if haskey(valid_colnames, row.experiment)
                push!(valid_colnames[row.experiment], row.colname)
            else
                valid_colnames[row.experiment] = Set([row.colname])
            end
        end

        # If we didn't already make a copy, we do so. Again, this is 
        # just to avoid modifying x.experiments in place in case
        # 'x' was a shallow copy of some not-to-be-modified MAE.
        if ecopy == nothing
            x.experiments = copy(x.experiments)
        end

        for (k, v) in x.experiments
            names = coldata(v)[!,"name"]
            valid = valid_colnames[k]

            keep = Vector{Bool}(undef, length(names))
            counter = 0
            for i in 1:length(names)
                keep[i] = names[i] in valid
                counter += Integer(keep[i])
            end

            # Avoid creating a copy unless it is strictly necessary.
            if counter != length(keep)
                x.experiments[k] = v[:,keep]
            end
        end
    end

    return x
end

"""
    dropunused(x; kwargs...)

Return a new `MultiAssayExperiment` where unused samples, experiments or column names are removed.
This makes a copy of `x` and passes it (and any keyword arguments in `kwargs`) to [`dropunused!`](@ref);
see the latter function for more details.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = MultiAssayExperiments.exampleobject();

julia> y = filtersamplemap(x; experiments = "bar"); # Only keeping experiment 'bar'

julia> dropunused(y) # We see that 'foo' is dropped
MultiAssayExperiment object
  experiments(1): bar
  sampledata(2): name disease
  metadata(1): version
```
"""
function dropunused(x::MultiAssayExperiment; kwargs...)
    y = copy(x)
    dropunused!(y; kwargs...)
    return y
end

