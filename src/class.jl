function harvest_all_colname(experiments::OrderedDict{String, SummarizedExperiment})
    all_names = OrderedSet{String}()
    for (key, val) in experiments
        cd = coldata(val)
        curnames = cd[!,"name"]

        if !isa(curnames, AbstractVector{<:AbstractString})
            throw(ErrorException("'name' column should only contain strings in column data of experiment '" * key * "'"))
        end
        if !allunique(curnames)
            throw(ErrorException("column names in experiment '" * key *"' must be unique"))
        end

        for n in curnames
            push!(all_names, n)
        end
    end
    return all_names
end

function check_sampledata(sampledata)
    if size(sampledata)[2] < 0 || names(sampledata)[1] != "name"
        throw(ErrorException("'sampledata' should contain at least 1 column named 'name'"))
    end

    samp_names = sampledata[!,1]
    if !isa(samp_names, AbstractVector{<:AbstractString})
        throw(ErrorException("'name' column of 'sampledata' should be a string vector"))
    end

    if !allunique(samp_names)
        throw(ErrorException("'name' column of 'sampledata' should contain unique values"))
    end
end

function check_samplemap(samplemap) 
    expected = ["sample", "experiment", "colname"]
    if size(samplemap)[2] != 3 || names(samplemap) != expected
        throw(ErrorException("'samplemap' should contain columns 'sample', 'experiment' and 'colname'"))
    end

    for field in expected
        if !isa(samplemap[!,field], AbstractVector{<:AbstractString})
            throw(ErrorException("'" * field * "' column of 'samplemap' should be a string vector"))
        end
    end
end

"""
The `MultiAssayExperiment` class is a Bioconductor container for multimodal studies.
This is basically a list of `SummarizedExperiment` objects, each of which represents a particular experimental modality.
A mapping table specifies the relationships between the columns of each `SummarizedExperiment` and a conceptual "sample",
assuming that each sample has data for zero, one or multiple modalities. 
A sample can be defined as anything from a cell line culture to an individual patient, depending on the context.

The central idea is to use the sample mapping to easily filter the `MultiAssayExperiment` based on the samples of interest.
For example, a user can call [`multifilter`](@ref) to only keep the columns of each `SummarizedExperiment` that correspond to desired samples via the sample mapping.
This facilitates coordination across multiple modalities without needing to manually subset each experiment.
We also store sample-level annotations in a sample data `DataFrame`,
where they can be easily attached to the `coldata` of a `SummarizedExperiment` for further analyses.

This implementation makes a few changes from the original Bioconductor implementation.
We do not consider the `MultiAssayExperiment` to contain any "columns", as this was unnecessarily confusing.
The previous `colData` field has thus been renamed to `sampledata`, to reflect the fact that we are operating on samples.
We are also much more relaxed about harmonization between the experiments, sample mapping, and sample data -
or more specifically, we don't harmonize at all, allowing greater flexibility in storage and manipulation.
"""
mutable struct MultiAssayExperiment
    experiments::OrderedDict{String, SummarizedExperiment}
    sampledata::DataFrame
    samplemap::DataFrame
    metadata::Dict{String,Any}

    @doc """
        MultiAssayExperiment()

    Creates an empty `MultiAssayExperiment` object.

    # Examples
    ```jldoctest
    julia> using MultiAssayExperiments

    julia> MultiAssayExperiment()
    MultiAssayExperiment object
      experiments(0):
      sampledata(1): name
      metadata(0):
    ```
    """
    function MultiAssayExperiment()
        samp = DataFrame(sample = Vector{String}(), experiment = Vector{String}(), colname = Vector{String}()) 
        cd = DataFrame(name = Vector{String}())
        new(
            Dict{String, SummarizedExperiment}(),
            cd,
            samp, 
            Dict{String,Any}()
        )
    end

    @doc """
        MultiAssayExperiment(experiments)

    Creates an `MultiAssayExperiment` object from a set of `experiments`.
    The per-sample column data and sample mapping is automatically created from the union of column names from all `experiments`.

    # Examples
    ```jldoctest
    julia> using MultiAssayExperiments

    julia> using SummarizedExperiments

    julia> exp = OrderedDict{String, SummarizedExperiment}();

    julia> exp["foo"] = SummarizedExperiments.exampleobject(100, 10);

    julia> exp["bar"] = SummarizedExperiments.exampleobject(50, 20);

    julia> out = MultiAssayExperiment(exp)
    MultiAssayExperiment object
      experiments(2): foo bar
      sampledata(1): name
      metadata(0):
    ```
    """
    function MultiAssayExperiment(experiments::OrderedDict{String, SummarizedExperiment})
        # Gather all the unique column names and use them to create a column data entry.
        all_names = harvest_all_colname(experiments)
        union = [x for x in all_names]
        dummy_cd = DataFrame(name = union)

        # Creating a dummy sample mapping.
        all_exp = Vector{String}()
        all_samp = Vector{String}()
        for (key, val) in experiments
            tmp = Vector{String}(undef, size(val)[2])
            fill!(tmp, key)
            append!(all_exp, tmp)

            cd = coldata(val)
            curnames = cd[!,"name"]
            append!(all_samp, curnames)
        end
        mapping = DataFrame(sample = all_samp, experiment = all_exp, colname = copy(all_samp))

        new(
            experiments, 
            dummy_cd, 
            mapping, 
            Dict{String, Any}()
        )
    end

    @doc """
        MultiAssayExperiment(experiments, sampledata, samplemap, metadata = Dict{String,Any}())

    Creates a new `MultiAssayExperiment` from its components.

    `experiments` should contain ordered pairs of experiment names and `SummarizedExperiment` objects.
    Each `SummarizedExperiment` may contain any number and identity for the rows.
    However, the column names must be non-nothing and unique within each object.

    Each row of `sampledata` corresponds to a conceptual sample.
    The first column should be called `name` and contain the names of the samples in a `Vector{String}`.
    Sample names are arbitrary but should be unique.
    Any number and type of other columns may be provided, usually containing sample-level annotations.

    The `samplemap` table is expected to have 3 `Vector{String}` columns - `sample`, `experiment` and `colname` -
    specifying the correspondence between each conceptual sample and the columns of a particular `SummarizedExperiment`.
    See [`setsamplemap!`](@ref) for more details on the expected format.

    Note that values in the `samplemap` columns need not have a 1:1 match to their cross-referenced target; 
    any values unique to one or the other will be ignored in methods like [`expandsampledata`](@ref) and [`filtersamplemap`](@ref).
    This allows users to flexibly manipulate the object without constantly hitting validity checks.

    The `metadata` stores other annotations unrelated to the samples.

    # Examples
    ```jldoctest
    julia> using MultiAssayExperiments

    julia> using SummarizedExperiments

    julia> exp = OrderedDict{String, SummarizedExperiment}();

    julia> exp["foo"] = SummarizedExperiments.exampleobject(100, 2);

    julia> exp["bar"] = SummarizedExperiments.exampleobject(50, 5);

    julia> cd = DataFrame(
               name = ["Aaron", "Michael", "Jayaram", "Sebastien", "John"],
               disease = ["good", "bad", "good", "bad", "very bad"]
           );

    julia> sm = DataFrame(
               sample = ["Aaron", "Michael", "Aaron", "Michael", "Jayaram", "Sebastien", "John"],
               experiment = ["foo", "foo", "bar", "bar", "bar", "bar", "bar"],
               colname = ["Patient1", "Patient2", "Patient1", "Patient2", "Patient3", "Patient4", "Patient5"]
           );

    julia> using MultiAssayExperiments;

    julia> out = MultiAssayExperiment(exp, cd, sm)
    MultiAssayExperiment object
      experiments(2): foo bar
      sampledata(2): name disease
      metadata(0):
    ```
    """
    function MultiAssayExperiment(
            experiments::OrderedDict{String, SummarizedExperiment},
            sampledata::DataFrame,
            samplemap::DataFrame,
            metadata::Dict{String, Any} = Dict{String, Any}()
        )

        # Running through sanity checks.
        check_sampledata(sampledata)
        harvest_all_colname(experiments)
        check_samplemap(samplemap)

        new(
            experiments,
            sampledata,
            samplemap,
            metadata
        )
    end
end
