"""
    copy(x::MultiAssayExperiment)

Return a copy of `x`, where all components are identically-same as those in `x`.

# Examples
```jldoctest
julia> using MultiAssayExperiments, DataFrames

julia> x = exampleobject();

julia> x2 = copy(x);

julia> setsampledata!(x2, DataFrame(name=["A", "B"]));

julia> size(sampledata(x))
(5, 2)

julia> size(sampledata(x2)) # Change to reference is only reflected in x2.
(2, 1)

julia> stuff = experiments(x);

julia> delete!(stuff, "bar");

julia> collect(keys(experiments(x2)))
1-element Vector{String}:
 "foo"
```
"""
function Base.copy(x::MultiAssayExperiment)
    output = MultiAssayExperiment()

    output.experiments = x.experiments
    output.sampledata = x.sampledata
    output.samplemap = x.samplemap
    output.metadata = x.metadata

    return output
end

"""
    deepcopy(x::MultiAssayExperiment)

Return a deep copy of `x` and all of its components.

# Examples
```jldoctest
julia> using MultiAssayExperiments, DataFrames

julia> x = exampleobject();

julia> x2 = deepcopy(x);

julia> insertcols!(sampledata(x), 2, "WHEE" => 1:5); # References now point to different objects.

julia> names(sampledata(x2))
2-element Vector{String}:
 "name"
 "disease"
```
"""
function Base.deepcopy(x::MultiAssayExperiment)
    output = MultiAssayExperiment()

    output.experiments = deepcopy(x.experiments)
    output.sampledata = deepcopy(x.sampledata)
    output.samplemap = deepcopy(x.samplemap)
    output.metadata = deepcopy(x.metadata)

    return output
end

function scat(io::IO, names::Vector{String})
    if length(names) < 5
        for n in names
            print(io, " " * n)
        end
    else
        print(io, " " * names[1])
        print(io, " " * names[2])
        print(io, " ...")
        print(io, " " * names[length(names)-1])
        print(io, " " * names[length(names)])
    end
end

"""
    print(io::IO, x::MultiAssayExperiment)

Print a summary of `x`.
"""
function Base.show(io::IO, x::MultiAssayExperiment)
    print(io, string(typeof(x)) * " object\n")

    print(io, "  experiments(" * string(length(experiments(x))) * "):")
    scat(io, collect(keys(experiments(x))))
    print(io, "\n")

    print(io, "  " * "sampledata(" * string(size(sampledata(x))[2]) * "):")
    scat(io, names(sampledata(x)))
    print(io, "\n")

    print(io, "  " * "metadata(" * string(length(metadata(x))) * "):")
    scat(io, collect(keys(metadata(x))))
end 
