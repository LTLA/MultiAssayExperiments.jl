# MultiAssayExperiments for Julia

## Overview

The [**MultiAssayExperiment** package](https://bioconductor.org/packages/MultiAssayExperiment) provides Bioconductor's standard structure for multimodal datasets.
This repository ports the basic `MultiAssayExperiment` functionality from R to Julia,
allowing Julians to conveniently manipulate analysis-ready datasets in the same fashion as R/Bioconductor workflows.

The `MultiAssayExperiment` class is effectively a wrapper around multiple [`SummarizedExperiment`](https://ltla.github.io/SummarizedExperiments.jl) objects,
each of which usually represents a different data modality, e.g., gene expression, protein intensity.
The sophistication lies in the relationships between columns of the various `SummarizedExperiment`s.
A "sample" may map to zero, one or many columns in any of the individual `SummarizedExperiment`s,
and many of the `MultiAssayExperiment` methods are focused on exploiting these relationships for convenient filtering of the dataset.

Check out [Figure 1](https://bioconductor.org/packages/release/bioc/vignettes/MultiAssayExperiment/inst/doc/MultiAssayExperiment.html) of the **MultiAssayExperiment** vignette for more details,
though note that this package does make a few changes from the original Bioconductor implementation.

## Quick start

Users may install this package from the GitHub repository through the usual process on the Pkg REPL:

```julia
add https://github.com/LTLA/MultiAssayExperiments.jl
```

And then:

```julia
julia> using MultiAssayExperiments, SummarizedExperiments

julia> mae = MultiAssayExperiments.exampleobject()
MultiAssayExperiment object
  experiments(2): foo bar
  sampledata(2): name disease
  metadata(1): version

julia> se = experiment(mae, "bar")
50x8 SummarizedExperiments.SummarizedExperiment
  assays(3): foo bar whee
  rownames: Gene1 Gene2 ... Gene49 Gene50
  rowdata(2): name Type
  colnames: bar1 bar2 ... bar7 bar8
  coldata(3): name Treatment Response
  metadata(1): version

julia> SummarizedExperiments.coldata(experiment(mae, "bar"; sampledata = true))
8×4 DataFrame
 Row │ name    Treatment  Response   disease  
     │ String  String     Float64    String   
─────┼────────────────────────────────────────
   1 │ bar1    drug2      0.841273   bad
   2 │ bar2    normal     0.523172   bad
   3 │ bar3    drug1      0.253657   good
   4 │ bar4    normal     0.613006   good
   5 │ bar5    drug1      0.0986848  bad
   6 │ bar6    drug1      0.610145   bad
   7 │ bar7    normal     0.179339   very bad
   8 │ bar8    normal     0.832958   very bad

julia> sub1 = multifilter(mae; samples = ["Patient1", "Patient3"]);

julia> experiment(sub1, "bar")
50x2 SummarizedExperiments.SummarizedExperiment
  assays(3): foo bar whee
  rownames: Gene1 Gene2 ... Gene49 Gene50
  rowdata(2): name Type
  colnames: bar3 bar4
  coldata(3): name Treatment Response
  metadata(1): version

julia> sub2 = multifilter(mae; experiments = "foo")
MultiAssayExperiment object
  experiments(1): foo
  sampledata(2): name disease
  metadata(1): version
```

## Class definition

```@docs
MultiAssayExperiment
```

## Constructors

```@docs
MultiAssayExperiment(
    experiments::OrderedDict{String, SummarizedExperiments.SummarizedExperiment},
    sampledata::DataFrame,
    samplemap::DataFrame,
    metadata::Dict{String,Any} = Dict{String,Any}()
)
```

```@docs
MultiAssayExperiment(experiments::OrderedDict{String, SummarizedExperiment})
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
setexperiment!(x::MultiAssayExperiment, value::SummarizedExperiment)
```

```@docs
setexperiments!(x::MultiAssayExperiment, value::OrderedDict{String, SummarizedExperiment})
```

```@docs
setsampledata!(x::MultiAssayExperiment, value::DataFrame)
```

```@docs
setsamplemap!(x::MultiAssayExperiment, value::DataFrame)
```

```@docs
setmetadata!(x::MultiAssayExperiment, value::Dict{String, Any})
```

## Filtering

```@docs
filtersamplemap!(x::MultiAssayExperiment)
```

```@docs
filtersamplemap(x::DataFrame)
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
