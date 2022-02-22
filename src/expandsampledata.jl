export expandsampledata

"""
    expandsampledata(x, experiment[, colnames])

Return a DataFrame containing the sample data for all or some of the column names in the chosen `experiment`.
Columns are the same as those in `sampledata(x)`.

If `colnames` is supplied, each row of the returned `DataFrame` corresponds to an entry of `colnames` and contains the data for the sample matching that column in the specified experiment.

If `colnames` is not supplied, each row of the returned `DataFrame` corresponds to a column of the specified experiment.

An error is raised if the requested columns do not have a matching sample in `samplemap(x)`. 
Use [`dropunused`](@ref) to remove unused columns from each experiment prior to calling this function.

A warning is raised if `sampledata(x)` contains duplicate sample names.
In such cases, data is taken from the first entry for each sample.

A warning is raised if `samplemap(x)` contains multiple occurrences of the same experiment/colname combination with a different sample.
In such cases, the first occurrence of the combination is used.

# Examples
```jldoctest
julia> using MultiAssayExperiments;

julia> x = exampleobject();

julia> expandsampledata(x, "foo")
10×2 DataFrame
 Row │ name      disease 
     │ String    String  
─────┼───────────────────
   1 │ Patient1  good
   2 │ Patient1  good
   3 │ Patient1  good
   4 │ Patient2  bad
   5 │ Patient2  bad
   6 │ Patient2  bad
   7 │ Patient3  good
   8 │ Patient3  good
   9 │ Patient3  good
  10 │ Patient4  bad

julia> expandsampledata(x, "foo", ["foo2", "foo1"])
2×2 DataFrame
 Row │ name      disease 
     │ String    String  
─────┼───────────────────
   1 │ Patient1  good
   2 │ Patient1  good
```
"""
function expandsampledata(x::MultiAssayExperiment, exp::String)
    names = SummarizedExperiments.coldata(experiment(x, exp))[!,"name"]
    return expandsampledata(x, exp, names)
end

function expandsampledata(x::MultiAssayExperiment, exp::String, colnames::Vector{String})
    sm = samplemap(x)
    collated = Dict{String,String}()
    for r in eachrow(sm)
        if r.experiment == exp
            if haskey(collated, r.colname)
                if collated[r.colname] != r.sample
                    @warn "multiple rows in 'samplemap(x)' for '" * sample * "' in '" * exp * "', using the first only"
                end
            else 
                collated[r.colname] = r.sample
            end
        end
    end

    samples = Dict{String,Int}()
    sd = sampledata(x)
    sn = sd[!,"name"]
    for s in 1:length(sn)
        sample = sn[s]
        if haskey(samples, sample)
            @warn "multiple rows in 'sampledata(x)' for '" * sample * "', using the first only"
            continue
        end
        samples[sample] = s
    end

    indices = Vector{Int}(undef, length(colnames))
    for c in 1:length(colnames)
        colname = colnames[c]
        if !haskey(collated, colname)
            throw(ErrorException("failed to find column name '" * colname * "' in the sample mapping for experiment '" * exp * "'"))
        end

        x = collated[colname];
        if !haskey(samples, x)
            throw(ErrorException("failed to find sample name '" * x * "' in the sample data"))
        end

        indices[c] = samples[x]
    end

    return sd[indices,:]
end
