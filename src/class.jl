export MultiAssayExperiment
import SummarizedExperiments
import DataStructures
import DataFrames

function harvest_all_colname(experiments::DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment})
    all_names = DataStructures.OrderedSet{String}()
    for (key, val) in experiments
        cd = SummarizedExperiments.coldata(val)
        curnames = cd[!,"name"]

        if isa(curnames, Vector{Nothing})
            throw(ErrorException("nothing names detected for experiment '" * key * "'"))
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
    if !isa(samp_names, Vector{String})
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
        if !isa(samplemap[!,field], Vector{String})
            throw(ErrorException("'" * field * "' column of 'samplemap' should be a string vector"))
        end
    end

    if (!allunique(eachrow(samplemap)))
        throw(ErrorException("'samplemap' should not contain duplicate rows"))
    end
end


"""
The `MultiAssayExperiment` class is a Bioconductor container for multimodal studies.
This is basically a list of `SummarizedExperiment` objects, each of which represents a particular experimental modality.
A mapping table specifies the relationships between the columns of each `SummarizedExperiment` and a conceptual "sample",
assuming that each sample has data for zero, one or multiple modalities. 
A sample can be defined as anything from a cell line culture to an individual patient, depending on the context.

This implementation makes a few changes from the original Bioconductor implementation.
We do not consider the `MultiAssayExperiment` to contain any "columns", as this was unnecessarily confusing.
The previous `colData` field has thus been renamed to `sampledata`, to reflect the fact that we are operating on samples.
We are also much more relaxed about harmonization between the experiments, sample mapping, and sample data -
or more specifically, we don't harmonize at all, allowing greater flexibility in storage and manipulation.
"""
mutable struct MultiAssayExperiment
    experiments::DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment}
    sampledata::DataFrames.DataFrame
    samplemap::DataFrames.DataFrame
    metadata::Dict{String,Any}

    """
        MultiAssayExperiment()

    Creates an empty `MultiAssayExperiment` object.

    # Examples
    ```jldoctest
    julia> MultiAssayExperiment();
    ```
    """
    function MultiAssayExperiment()
        samp = DataFrames.DataFrame(sample = Vector{String}(), experiment = Vector{String}(), colname = Vector{String}()) 
        cd = DataFrames.DataFrame(name = Vector{String}())
        new(
            Dict{String,SummarizedExperiments.SummarizedExperiment}(),
            cd,
            samp, 
            Dict{String,Any}()
        )
    end

    """
        MultiAssayExperiment(experiments)

    Creates an `MultiAssayExperiment` object from a set of `experiments`.
    The per-sample column data and sample mapping is automatically created from the union of column names from all `experiments`.

    # Examples
    ```jldoctest
    julia> using SummarizedExperiments, DataStructures;

    julia> exp = OrderedDict{String,SummarizedExperiment}();

    julia> exp["foo"] = exampleobject(100, 10);

    julia> exp["bar"] = exampleobject(50, 20);

    julia> out = MultiAssayExperiment(exp);
    ```
    """
    function MultiAssayExperiment(experiments::DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment})
        # Gather all the unique column names and use them to create a column data entry.
        all_names = harvest_all_colname(experiments)
        union = [x for x in all_names]
        dummy_cd = DataFrames.DataFrame(name = union)

        # Creating a dummy sample mapping.
        all_exp = Vector{String}()
        all_samp = Vector{String}()
        for (key, val) in experiments
            tmp = Vector{String}(undef, size(val)[2])
            fill!(tmp, key)
            append!(all_exp, tmp)

            cd = SummarizedExperiments.coldata(val)
            curnames = cd[!,"name"]
            append!(all_samp, curnames)
        end
        mapping = DataFrames.DataFrame(sample = all_samp, experiment = all_exp, colname = copy(all_samp))

        new(
            experiments, 
            dummy_cd, 
            mapping, 
            Dict{String,Any}()
        )
    end

    """
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
    Values in the `sample` column will be cross-referenced to values in the `name` column of the `sampledata`;
    values in the `experiment` column will be cross-referenced to the keys of `experiments`;
    and the `colname` column will be cross-referenced to the column names of each `SummarizedExperiment`.
    Note that values in the columns need not have a 1:1 match to their cross-referenced target; 
    any missing values in one or the other will be ignored in the methods.
    Rows of the table should be unique.

    The `metadata` stores other annotations unrelated to the samples.

    # Examples
    ```jldoctest
    julia> using SummarizedExperiments, DataStructures, DataFrames;

    julia> exp = OrderedDict{String,SummarizedExperiment}();

    julia> exp["foo"] = exampleobject(100, 2);

    julia> exp["bar"] = exampleobject(50, 5);

    julia> cd = DataFrames.DataFrame(
               name = ["Aaron", "Michael", "Jayaram", "Sebastien", "John"],
               disease = ["good", "bad", "good", "bad", "very bad"]
           );

    julia> sm = DataFrames.DataFrame(
               sample = ["Aaron", "Michael", "Aaron", "Michael", "Jayaram", "Sebastien", "John"],
               experiment = ["foo", "foo", "bar", "bar", "bar", "bar", "bar"],
               colname = ["Patient1", "Patient2", "Patient1", "Patient2", "Patient3", "Patient4", "Patient5"]
           );

    julia> using MultiAssayExperiments;

    julia> out = MultiAssayExperiment(exp, cd, sm);
    ```
    """
    function MultiAssayExperiment(
            experiments::DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment},
            sampledata::DataFrames.DataFrame,
            samplemap::DataFrames.DataFrame,
            metadata::Dict{String,Any} = Dict{String,Any}()
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
