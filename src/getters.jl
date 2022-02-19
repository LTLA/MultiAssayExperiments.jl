export experiments, experiment, sampledata, samplemap, metadata
import DataStructures
import DataFrames
import SummarizedExperiments

"""
    experiments(x)

Return an ordered dictionary containing all experiments in the `MultiAssayExperiment` `x`.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = exampleobject();

julia> collect(keys(experiments(x)))
2-element Vector{String}:
 "foo"
 "bar"
```
"""
function experiments(x::MultiAssayExperiment)
    return x.experiments
end

"""
    experiment(x[, i]; sampledata = false)

Extract the specified `SummarizedExperiment` from a `MultiAssayExperiment` `x`.
`i` may be a positive integer no greater than the number of experiments in `x`,
or a string specifying the name of the desired experiment.
If `i` is not specified, it defaults to the first experiment in `x`.

If `sampledata = true`, we attempt to add the sample data of `x` to the `coldata` of the returned `SummarizedExperiment`.
This is done by subsetting `sampledata(x)` based on sample mapping to the columns of the returned `SummarizedExperiment`.
Note that this may not be possible if there are columns of the `SummarizedExperiment` that are not present in the sample mapping,
in which case an error is raised - use [`dropunused`](@ref) in that case.
If there are columns in the `sampledata(x)` and the `coldata` of the `SummarizedExperiment` with the same name but different values,
the former are omitted with a warning.

Note that, if `sampledata = true`, the returned `SummarizedExperiment` will be a copy of the relevant experiment in `x`.
If `false`, the returned object will be a reference.

# Examples
```jldoctest
julia> using MultiAssayExperiments;

julia> x = exampleobject();

julia> experiment(x)
100x10 SummarizedExperiments.SummarizedExperiment
  assays(3): foo bar whee
  rownames: Gene1 Gene2 ... Gene99 Gene100
  rowdata(2): name Type
  colnames: foo1 foo2 ... foo9 foo10
  coldata(3): name Treatment Response
  metadata(1): version

julia> experiment(x, 1); # same result

julia> experiment(x, "foo");

julia> experiment(x, "foo", sampledata = true) # add sample data
100x10 SummarizedExperiment
  assays(3): foo bar whee
  rownames: Gene1 Gene2 ... Gene99 Gene100
  rowdata(2): name Type
  colnames: foo1 foo2 ... foo9 foo10
  coldata(4): name Treatment Response disease
  metadata(1): version
```
"""
function experiment(x::MultiAssayExperiment; sampledata = false)
    return experiment(x, 1, sampledata = sampledata)
end

function safely_add_columns!(host, other, experiment)
    for n in names(other)
        if (n == "name") 
            continue # skipping the name.
        end

        src = other[!,n]

        if n in names(host)
            if src != host[!,n]
                @warn "omitting sample data column '" * n * "' with conflict in column data of experiment '" * experiment * "'" 
            end
            continue
        end

        host[!,n] = src
    end
end

function experiment(x::MultiAssayExperiment, i::Int; sampledata = false)
    counter = 1
    for (key, val) in experiments(x)
        if (i == counter)
            if !sampledata
                return val
            else
                sd = extractsampledata(x, key, coldata(val)[!,"name"])
                val2 = copy(val)
                cd = copy(SummarizedExperiments.coldata(val2))
                safely_add_columns!(cd, sd, key)
                SummarizedExperiments.setcoldata!(val2, cd)
                return val2
            end
        end
        counter += 1
    end
    throw(BoundsError("experiment " * string(i) * " is out of range (" * length(experiments(x)) * " experiments available)"))
end

function experiment(x::MultiAssayExperiment, i::String; sampledata = false)
    val = x.experiments[i]
    if !sampledata
        return val
    else
        sd = extractsampledata(x, i, SummarizedExperiments.coldata(val)[!,"name"])
        val2 = copy(val)
        cd = copy(SummarizedExperiments.coldata(val2))
        safely_add_columns!(cd, sd, i)
        SummarizedExperiments.setcoldata!(val2, cd)
        return val2
    end
end

"""
    sampledata(x, check = true)

Return a `DataFrame` containing the sample data in the `MultiAssayExperiment` `x`.

The returned object should contain `name` as the first column, containing a vector of unique strings.
If `check = true`, the function will check the validity of the sample data before returning it.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = exampleobject();

julia> names(sampledata(x))
2-element Vector{String}:
 "name"
 "disease"
```
"""
function sampledata(x::MultiAssayExperiment, check::Bool = true)
    output = x.sampledata
    if check
        check_sampledata(output)
    end
    return output
end

"""
    samplemap(x)

Return an ordered dictionary containing the sample mapping from the `MultiAssayExperiment` `x`.

The returned object should contain the `sample`, `experiment` and `colname` columns in that order.
Each column should contain a vector of strings, and rows should be unique.
If `check = true`, the function will check the validity of the sample data before returning it.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = exampleobject();

julia> names(samplemap(x))
3-element Vector{String}:
 "sample"
 "experiment"
 "colname"
```
"""
function samplemap(x::MultiAssayExperiment, check::Bool = true)
    output = x.samplemap
    if check
        check_samplemap(output)
    end
    return output
end

"""
    metadata(x)

Return a dictionary containing the metadata from the `MultiAssayExperiment` `x`.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = exampleobject();

julia> collect(keys(metadata(x)))
1-element Vector{String}:
 "version"
```
"""
function metadata(x::MultiAssayExperiment)
    return x.metadata
end
