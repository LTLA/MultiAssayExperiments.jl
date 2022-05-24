module MultiAssayExperiments

export setexperiments!, setexperiment!, setsampledata!, setsamplemap!, setmetadata!
using SummarizedExperiments

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

include("multifilter.jl")
export multifilter, multifilter!

include("filtersamplemap.jl")
export filtersamplemap, filtersamplemap!

include("dropunused.jl")
export dropunused, dropunused!

end # module
