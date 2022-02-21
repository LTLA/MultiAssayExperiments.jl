# MultiAssayExperiments for Julia

## Quick start

Users may install this package from the GitHub repository through the usual process on the Pkg REPL:

```julia
add https://github.com/LTLA/MultiAssayExperiment.jl
```

And then:

## Class definition

```@docs
MultiAssayExperiment
```

## Constructors

```@docs
MultiAssayExperiment(
    experiments::DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment},
    sampledata::DataFrames.DataFrame,
    samplemap::DataFrames.DataFrame,
    metadata::Dict{String,Any} = Dict{String,Any}()
)
```

```@docs
MultiAssayExperiment(experiments::DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment})
```

```@docs
MultiAssayExperiment()
```

## Getters

```@docs
experiment(x::MultiAssayExperiment)
```

```@docs
experiments(x::MultiAssayExperiment)
```

```@docs
sampledata(x::MultiAssayExperiment)
```

```@docs
samplemap(x::MultiAssayExperiment)
```

```@docs
metadata(x::MultiAssayExperiment)
```

## Setters 

```@docs
setexperiment!(x::MultiAssayExperiment, value::SummarizedExperiments.SummarizedExperiment)
```

```@docs
setexperiments!(x::MultiAssayExperiment, value::DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment})
```

```@docs
setsampledata!(x::MultiAssayExperiment, value::DataFrames.DataFrame)
```

```@docs
setsamplemap!(x::MultiAssayExperiment, value::DataFrames.DataFrame)
```

```@docs
setmetadata!(x::MultiAssayExperiment, value::Dict{String,Any})
```

## Filtering

```@docs
filtersamplemap!(x::MultiAssayExperiment)
```

```@docs
filtersamplemap(x::DataFrames.DataFrame)
```

```@docs
dropunused!(x::MultiAssayExperiment)
```

```@docs
dropunused(x::MultiAssayExperiment)
```

```@docs
multifilter!(x::MultiAssayExperiment)
```

```@docs
multifilter(x::MultiAssayExperiment)
```

## Miscellaneous

```@docs
Base.copy(x::MultiAssayExperiment)
```

```@docs
Base.deepcopy(x::MultiAssayExperiment)
```

```@docs
Base.show(io::IO, x::MultiAssayExperiment)
```

```@docs
expandsampledata(x::MultiAssayExperiment, exp::String)
```

```@docs
exampleobject()
```

## Contact

This package is maintained by Aaron Lun ([**@LTLA**](https://github.com/LTLA)).
If you have bug reports or feature requests, please post them as issues at the [GitHub repository](https://github.com/LTLA/MultiAssayExperiments.jl/issues).
