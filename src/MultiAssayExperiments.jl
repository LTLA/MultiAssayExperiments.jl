module MultiAssayExperiments

using Reexport
@reexport using SummarizedExperiments
@reexport using DataStructures: OrderedDict, OrderedSet
@reexport using DataFrames: DataFrame, filter

include("class.jl")
export MultiAssayExperiment

include("miscellaneous.jl")
include("exampleobject.jl")
export exampleobject

include("expandsampledata.jl")
export expandsampledata

include("getters.jl")
export experiments, experiment, sampledata, samplemap, metadata

include("setters.jl")
export setexperiments!, setexperiment!, setsampledata!, setsamplemap!, setmetadata!

include("multifilter.jl")
export multifilter, multifilter!

include("filtersamplemap.jl")
export filtersamplemap, filtersamplemap!

include("dropunused.jl")
export dropunused, dropunused!

end # module
