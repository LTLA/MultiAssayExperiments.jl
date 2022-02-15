export experiments, sampledata, samplemap, metadata, setexperiments!, setsampledata!, setsamplemap!, setmetadata!
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
    setexperiments!(x, value)

Set the experiments in the `MultiAssayExperiment` `x` to the `OrderedDict` `value`.
This returns a reference to the modified `x`.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = exampleobject();

julia> y = copy(experiments(x));

julia> delete!(y, "foo");

julia> setexperiments!(x, y);

julia> collect(keys(experiments(x)))
1-element Vector{String}:
 "bar"
```
"""
function setexperiments!(x::MultiAssayExperiment, value::DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment})
    x.experiments = value;
    return x
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
    setsampledata!(x, value)

Set the sample data in the `MultiAssayExperiment` `x` to the `DataFrame` `value`.

The returned object should contain `name` as the first column, containing a vector of unique strings.
If `check = true`, the function will check the validity of the sample data before returning it.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = exampleobject();

julia> sd = copy(sampledata(x));

julia> sd[!,"stuff"] = [rand() for i in 1:size(sd)[1]];

julia> setsampledata!(x, sd);

julia> names(sampledata(x))
3-element Vector{String}:
 "name"
 "disease"
 "stuff"
```
"""

function setsampledata!(x::MultiAssayExperiment, value::DataFrames.DataFrame)
    check_sampledata(value)
    x.sampledata = value
    return x
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
    setsamplemap!(x, value)

Set the sample mapping in the `MultiAssayExperiment` `x` to a `DataFrame` `value`.
This returns a reference to the modified `x`.

`value` should contain the `sample`, `experiment` and `colname` columns in that order.
Each column should contain a vector of strings, and rows should be unique.

`sample` should (but is not required to) correspond to the names of samples in `sampledata(x)`;
`experiment` should (but is not required to) correspond to the keys of `experiments(x)`;
and `colname` should (but is not required to) correspond to the columns of the corresponding `SummarizedExperiment` in `experiments(x)`.
This correspondence is used for convenient subsetting and extraction in the various `extract` methods.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = exampleobject();

julia> y = samplemap(x)[1:10,:];

julia> setsamplemap!(x, y);

julia> size(samplemap(x))[1]
10
```
"""
function setsamplemap!(x::MultiAssayExperiment, value::DataFrames.DataFrame)
    check_samplemap(value)
    x.samplemap = value
    return x
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

"""
    setmetadata!(x, value)

Set the metadata of a `MultiAssayExperiment` `x` to a dictionary `value`.
This returns a reference to the modified `x`.

# Examples
```jldoctest
julia> using MultiAssayExperiments

julia> x = exampleobject();

julia> meta = copy(metadata(x));

julia> meta["version"] = "0.2.0";

julia> setmetadata!(x, meta);

julia> metadata(x)["version"]
"0.2.0"
```
"""
function setmetadata!(x::MultiAssayExperiment, value::Dict{String,Any})
    x.metadata = value
    return x
end
