export setexperiments!, setexperiment!, setsampledata!, setsamplemap!, setmetadata!
import DataStructures
import DataFrames
import SummarizedExperiments

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
    setexperiment!(x[, i], value)

Set experiment `i` in `MultiAssayExperiment` `x` to the `SummarizedExperiment` `value`.
This returns a reference to the modified `x`.

`i` may be a positive integer, in which case it should be no greater than the length of `experiments(x)`.
It may also be a string specifying a new or existing experiment in `x`.
If omitted, we set the first experiment by default.

# Examples
```jldoctest
julia> using MultiAssayExperiments;

julia> x = exampleobject();

julia> size(experiment(x, 2))
(50, 8)

julia> val = experiment(x);

julia> setexperiment!(x, 2, val);

julia> size(experiment(x, 2))
(100, 10)
```
"""
function setexperiment!(x::MultiAssayExperiment, value::SummarizedExperiments.SummarizedExperiment)
    return setexperiment!(x, 1, value)
end

function setexperiment!(x::MultiAssayExperiment, i::Int, value::SummarizedExperiments.SummarizedExperiment)
    counter = 1
    for key in keys(experiments(x))
        if i == counter
            x.experiments[key] = value
            return x
        end
        counter += 1
    end
    throw(BoundsError("experiment " * string(i) * " is out of range (" * length(experiments(x)) * " experiments available)"))
end

function setexperiment!(x::MultiAssayExperiment, i::String, value::SummarizedExperiments.SummarizedExperiment)
    x.experiments[i] = value
    return x
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
