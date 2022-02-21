var documenterSearchIndex = {"docs":
[{"location":"#MultiAssayExperiments-for-Julia","page":"Home","title":"MultiAssayExperiments for Julia","text":"","category":"section"},{"location":"#Quick-start","page":"Home","title":"Quick start","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Users may install this package from the GitHub repository through the usual process on the Pkg REPL:","category":"page"},{"location":"","page":"Home","title":"Home","text":"add https://github.com/LTLA/MultiAssayExperiment.jl","category":"page"},{"location":"","page":"Home","title":"Home","text":"And then:","category":"page"},{"location":"#Class-definition","page":"Home","title":"Class definition","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"MultiAssayExperiment","category":"page"},{"location":"#MultiAssayExperiments.MultiAssayExperiment","page":"Home","title":"MultiAssayExperiments.MultiAssayExperiment","text":"The MultiAssayExperiment class is a Bioconductor container for multimodal studies. This is basically a list of SummarizedExperiment objects, each of which represents a particular experimental modality. A mapping table specifies the relationships between the columns of each SummarizedExperiment and a conceptual \"sample\", assuming that each sample has data for zero, one or multiple modalities.  A sample can be defined as anything from a cell line culture to an individual patient, depending on the context.\n\nThe central idea is to use the sample mapping to easily filter the MultiAssayExperiment based on the samples of interest. For example, a user can call multifilter to only keep the columns of each SummarizedExperiment that correspond to desired samples via the sample mapping. This facilitates coordination across multiple modalities without needing to manually subset each experiment. We also store sample-level annotations in a sample data DataFrame, where they can be easily attached to the coldata of a SummarizedExperiment for further analyses.\n\nThis implementation makes a few changes from the original Bioconductor implementation. We do not consider the MultiAssayExperiment to contain any \"columns\", as this was unnecessarily confusing. The previous colData field has thus been renamed to sampledata, to reflect the fact that we are operating on samples. We are also much more relaxed about harmonization between the experiments, sample mapping, and sample data - or more specifically, we don't harmonize at all, allowing greater flexibility in storage and manipulation.\n\n\n\n\n\n","category":"type"},{"location":"#Constructors","page":"Home","title":"Constructors","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"MultiAssayExperiment(\n    experiments::DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment},\n    sampledata::DataFrames.DataFrame,\n    samplemap::DataFrames.DataFrame,\n    metadata::Dict{String,Any} = Dict{String,Any}()\n)","category":"page"},{"location":"#MultiAssayExperiments.MultiAssayExperiment-2","page":"Home","title":"MultiAssayExperiments.MultiAssayExperiment","text":"MultiAssayExperiment(experiments, sampledata, samplemap, metadata = Dict{String,Any}())\n\nCreates a new MultiAssayExperiment from its components.\n\nexperiments should contain ordered pairs of experiment names and SummarizedExperiment objects. Each SummarizedExperiment may contain any number and identity for the rows. However, the column names must be non-nothing and unique within each object.\n\nEach row of sampledata corresponds to a conceptual sample. The first column should be called name and contain the names of the samples in a Vector{String}. Sample names are arbitrary but should be unique. Any number and type of other columns may be provided, usually containing sample-level annotations.\n\nThe samplemap table is expected to have 3 Vector{String} columns - sample, experiment and colname - specifying the correspondence between each conceptual sample and the columns of a particular SummarizedExperiment. See setsamplemap! for more details on the expected format.\n\nNote that values in the samplemap columns need not have a 1:1 match to their cross-referenced target;  any values unique to one or the other will be ignored in methods like expandsampledata and filtersamplemap. This allows users to flexibly manipulate the object without constantly hitting validity checks.\n\nThe metadata stores other annotations unrelated to the samples.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> import SummarizedExperiments, DataStructures, DataFrames;\n\njulia> exp = DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment}();\n\njulia> exp[\"foo\"] = SummarizedExperiments.exampleobject(100, 2);\n\njulia> exp[\"bar\"] = SummarizedExperiments.exampleobject(50, 5);\n\njulia> cd = DataFrames.DataFrame(\n           name = [\"Aaron\", \"Michael\", \"Jayaram\", \"Sebastien\", \"John\"],\n           disease = [\"good\", \"bad\", \"good\", \"bad\", \"very bad\"]\n       );\n\njulia> sm = DataFrames.DataFrame(\n           sample = [\"Aaron\", \"Michael\", \"Aaron\", \"Michael\", \"Jayaram\", \"Sebastien\", \"John\"],\n           experiment = [\"foo\", \"foo\", \"bar\", \"bar\", \"bar\", \"bar\", \"bar\"],\n           colname = [\"Patient1\", \"Patient2\", \"Patient1\", \"Patient2\", \"Patient3\", \"Patient4\", \"Patient5\"]\n       );\n\njulia> using MultiAssayExperiments;\n\njulia> out = MultiAssayExperiment(exp, cd, sm)\nMultiAssayExperiment object\n  experiments(2): foo bar\n  sampledata(2): name disease\n  metadata(0):\n\n\n\n\n\n","category":"type"},{"location":"","page":"Home","title":"Home","text":"MultiAssayExperiment(experiments::DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment})","category":"page"},{"location":"#MultiAssayExperiments.MultiAssayExperiment-Tuple{OrderedCollections.OrderedDict{String, SummarizedExperiments.SummarizedExperiment}}","page":"Home","title":"MultiAssayExperiments.MultiAssayExperiment","text":"MultiAssayExperiment(experiments)\n\nCreates an MultiAssayExperiment object from a set of experiments. The per-sample column data and sample mapping is automatically created from the union of column names from all experiments.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> import SummarizedExperiments, DataStructures\n\njulia> exp = DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment}();\n\njulia> exp[\"foo\"] = SummarizedExperiments.exampleobject(100, 10);\n\njulia> exp[\"bar\"] = SummarizedExperiments.exampleobject(50, 20);\n\njulia> out = MultiAssayExperiment(exp)\nMultiAssayExperiment object\n  experiments(2): foo bar\n  sampledata(1): name\n  metadata(0):\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"MultiAssayExperiment()","category":"page"},{"location":"#MultiAssayExperiments.MultiAssayExperiment-Tuple{}","page":"Home","title":"MultiAssayExperiments.MultiAssayExperiment","text":"MultiAssayExperiment()\n\nCreates an empty MultiAssayExperiment object.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> MultiAssayExperiment()\nMultiAssayExperiment object\n  experiments(0):\n  sampledata(1): name\n  metadata(0):\n\n\n\n\n\n","category":"method"},{"location":"#Getters","page":"Home","title":"Getters","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"experiment(x::MultiAssayExperiment)","category":"page"},{"location":"#MultiAssayExperiments.experiment-Tuple{MultiAssayExperiment}","page":"Home","title":"MultiAssayExperiments.experiment","text":"experiment(x[, i]; sampledata = false)\n\nExtract the specified SummarizedExperiment from a MultiAssayExperiment x. i may be a positive integer no greater than the number of experiments in x, or a string specifying the name of the desired experiment. If i is not specified, it defaults to the first experiment in x.\n\nIf sampledata = true, we attempt to add the sample data of x to the coldata of the returned SummarizedExperiment. This is done by subsetting sampledata(x) based on sample mapping to the columns of the returned SummarizedExperiment - see expandsampledata for more details. If there are columns in the sampledata(x) and the coldata of the SummarizedExperiment with the same name but different values, the former are omitted with a warning.\n\nNote that, if sampledata = true, the returned SummarizedExperiment will be a copy of the relevant experiment in x. If false, the returned object will be a reference.\n\nExamples\n\njulia> using MultiAssayExperiments;\n\njulia> x = exampleobject();\n\njulia> experiment(x)\n100x10 SummarizedExperiments.SummarizedExperiment\n  assays(3): foo bar whee\n  rownames: Gene1 Gene2 ... Gene99 Gene100\n  rowdata(2): name Type\n  colnames: foo1 foo2 ... foo9 foo10\n  coldata(3): name Treatment Response\n  metadata(1): version\n\njulia> experiment(x, 1); # same result\n\njulia> experiment(x, \"foo\");\n\njulia> experiment(x, \"foo\", sampledata = true) # add sample data\n100x10 SummarizedExperiments.SummarizedExperiment\n  assays(3): foo bar whee\n  rownames: Gene1 Gene2 ... Gene99 Gene100\n  rowdata(2): name Type\n  colnames: foo1 foo2 ... foo9 foo10\n  coldata(4): name Treatment Response disease\n  metadata(1): version\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"experiments(x::MultiAssayExperiment)","category":"page"},{"location":"#MultiAssayExperiments.experiments-Tuple{MultiAssayExperiment}","page":"Home","title":"MultiAssayExperiments.experiments","text":"experiments(x)\n\nReturn an ordered dictionary containing all experiments in the MultiAssayExperiment x.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> collect(keys(experiments(x)))\n2-element Vector{String}:\n \"foo\"\n \"bar\"\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"sampledata(x::MultiAssayExperiment)","category":"page"},{"location":"#MultiAssayExperiments.sampledata-Tuple{MultiAssayExperiment}","page":"Home","title":"MultiAssayExperiments.sampledata","text":"sampledata(x, check = true)\n\nReturn a DataFrame containing the sample data in the MultiAssayExperiment x.\n\nThe returned object should contain name as the first column, containing a vector of unique strings. If check = true, the function will check the validity of the sample data before returning it.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> names(sampledata(x))\n2-element Vector{String}:\n \"name\"\n \"disease\"\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"samplemap(x::MultiAssayExperiment)","category":"page"},{"location":"#MultiAssayExperiments.samplemap-Tuple{MultiAssayExperiment}","page":"Home","title":"MultiAssayExperiments.samplemap","text":"samplemap(x)\n\nReturn an ordered dictionary containing the sample mapping from the MultiAssayExperiment x.\n\nThe returned object should contain the sample, experiment and colname columns in that order. Each column should contain a vector of strings, and rows should be unique. If check = true, the function will check the validity of the sample data before returning it.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> names(samplemap(x))\n3-element Vector{String}:\n \"sample\"\n \"experiment\"\n \"colname\"\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"metadata(x::MultiAssayExperiment)","category":"page"},{"location":"#MultiAssayExperiments.metadata-Tuple{MultiAssayExperiment}","page":"Home","title":"MultiAssayExperiments.metadata","text":"metadata(x)\n\nReturn a dictionary containing the metadata from the MultiAssayExperiment x.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> collect(keys(metadata(x)))\n1-element Vector{String}:\n \"version\"\n\n\n\n\n\n","category":"method"},{"location":"#Setters","page":"Home","title":"Setters","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"setexperiment!(x::MultiAssayExperiment, value::SummarizedExperiments.SummarizedExperiment)","category":"page"},{"location":"#MultiAssayExperiments.setexperiment!-Tuple{MultiAssayExperiment, SummarizedExperiments.SummarizedExperiment}","page":"Home","title":"MultiAssayExperiments.setexperiment!","text":"setexperiment!(x[, i], value)\n\nSet experiment i in MultiAssayExperiment x to the SummarizedExperiment value. This returns a reference to the modified x.\n\ni may be a positive integer, in which case it should be no greater than the length of experiments(x). It may also be a string specifying a new or existing experiment in x. If omitted, we set the first experiment by default.\n\nExamples\n\njulia> using MultiAssayExperiments;\n\njulia> x = exampleobject();\n\njulia> size(experiment(x, 2))\n(50, 8)\n\njulia> val = experiment(x);\n\njulia> setexperiment!(x, 2, val);\n\njulia> size(experiment(x, 2))\n(100, 10)\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"setexperiments!(x::MultiAssayExperiment, value::DataStructures.OrderedDict{String,SummarizedExperiments.SummarizedExperiment})","category":"page"},{"location":"#MultiAssayExperiments.setexperiments!-Tuple{MultiAssayExperiment, OrderedCollections.OrderedDict{String, SummarizedExperiments.SummarizedExperiment}}","page":"Home","title":"MultiAssayExperiments.setexperiments!","text":"setexperiments!(x, value)\n\nSet the experiments in the MultiAssayExperiment x to the OrderedDict value. This returns a reference to the modified x.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> y = copy(experiments(x));\n\njulia> delete!(y, \"foo\");\n\njulia> setexperiments!(x, y);\n\njulia> collect(keys(experiments(x)))\n1-element Vector{String}:\n \"bar\"\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"setsampledata!(x::MultiAssayExperiment, value::DataFrames.DataFrame)","category":"page"},{"location":"#MultiAssayExperiments.setsampledata!-Tuple{MultiAssayExperiment, DataFrames.DataFrame}","page":"Home","title":"MultiAssayExperiments.setsampledata!","text":"setsampledata!(x, value)\n\nSet the sample data in the MultiAssayExperiment x to the DataFrame value.\n\nThe returned object should contain name as the first column, containing a vector of unique strings. If check = true, the function will check the validity of the sample data before returning it.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> sd = copy(sampledata(x));\n\njulia> sd[!,\"stuff\"] = [rand() for i in 1:size(sd)[1]];\n\njulia> setsampledata!(x, sd);\n\njulia> names(sampledata(x))\n3-element Vector{String}:\n \"name\"\n \"disease\"\n \"stuff\"\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"setsamplemap!(x::MultiAssayExperiment, value::DataFrames.DataFrame)","category":"page"},{"location":"#MultiAssayExperiments.setsamplemap!-Tuple{MultiAssayExperiment, DataFrames.DataFrame}","page":"Home","title":"MultiAssayExperiments.setsamplemap!","text":"setsamplemap!(x, value)\n\nSet the sample mapping in the MultiAssayExperiment x to a DataFrame value. This returns a reference to the modified x.\n\nvalue should contain the sample, experiment and colname columns in that order. Each column should contain a vector of strings:\n\nValues of sample may (but are not required to) correspond to the names of samples in sampledata(x).\nValues of experiment may (but are not required to) correspond to the keys of experiments(x).\nValues of colname should (but are not required to) correspond to the columns of the corresponding SummarizedExperiment in the experiment of the same row.\n\nThis correspondence is used for convenient subsetting and extraction, e.g., expandsampledata, filtersamplemap. However, values in the sample mapping columns need not have a 1:1 match to their corresponding target;  any values unique to one or the other will be ignored in the relevant methods. This allows users to flexibly manipulate the object without constantly hitting validity checks.\n\nIt is legal (but highly unusual) for a given combination of experiment and colname to occur more than once. This may incur warnings in methods like expandsampledata.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> y = samplemap(x)[1:10,:];\n\njulia> setsamplemap!(x, y);\n\njulia> size(samplemap(x))[1]\n10\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"setmetadata!(x::MultiAssayExperiment, value::Dict{String,Any})","category":"page"},{"location":"#MultiAssayExperiments.setmetadata!-Tuple{MultiAssayExperiment, Dict{String, Any}}","page":"Home","title":"MultiAssayExperiments.setmetadata!","text":"setmetadata!(x, value)\n\nSet the metadata of a MultiAssayExperiment x to a dictionary value. This returns a reference to the modified x.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> meta = copy(metadata(x));\n\njulia> meta[\"version\"] = \"0.2.0\";\n\njulia> setmetadata!(x, meta);\n\njulia> metadata(x)[\"version\"]\n\"0.2.0\"\n\n\n\n\n\n","category":"method"},{"location":"#Filtering","page":"Home","title":"Filtering","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"filtersamplemap!(x::MultiAssayExperiment)","category":"page"},{"location":"#MultiAssayExperiments.filtersamplemap!-Tuple{MultiAssayExperiment}","page":"Home","title":"MultiAssayExperiments.filtersamplemap!","text":"filtersamplemap!(x; samples = nothing, experiments = nothing, colnames = nothing)\n\nModifies samplemap(x) in place by filtering based on filtersamplemap. A reference to the modified x is returned.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> filtersamplemap!(x; samples = [\"Patient1\", \"Patient2\"]);\n\njulia> samplemap(x)\n8×3 DataFrame\n Row │ sample    experiment  colname \n     │ String    String      String  \n─────┼───────────────────────────────\n   1 │ Patient1  foo         foo1\n   2 │ Patient1  foo         foo2\n   3 │ Patient1  foo         foo3\n   4 │ Patient2  foo         foo4\n   5 │ Patient2  foo         foo5\n   6 │ Patient2  foo         foo6\n   7 │ Patient2  bar         bar1\n   8 │ Patient2  bar         bar2\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"filtersamplemap(x::DataFrames.DataFrame)","category":"page"},{"location":"#MultiAssayExperiments.filtersamplemap-Tuple{DataFrames.DataFrame}","page":"Home","title":"MultiAssayExperiments.filtersamplemap","text":"filtersamplemap(x; samples = nothing, experiments = nothing, colnames = nothing)\n\nFilter the sample mapping DataFrame to the requested samples, experiments and column names. x can either be a MultiAssayExperiment or its samplemap.\n\nIf samples is nothing, it is not used for any filtering. Otherwise, it may be a vector or set of strings specifying the samples to retain. A single string may also be supplied.\n\nIf experiments is nothing, it is not used for any filtering. Otherwise, it may be a vector or set of strings specifying the experiments to retain. A single string may also be supplied.\n\nIf colnames is nothing, it is not used for any filtering. Otherwise, it may be a vector or set of strings specifying the columns to retain. A single string may also be supplied.\n\nA row of the sample mapping is only retained if it passes all supplied filters.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> filtersamplemap(samplemap(x); samples = [\"Patient1\", \"Patient2\"])\n8×3 DataFrame\n Row │ sample    experiment  colname \n     │ String    String      String  \n─────┼───────────────────────────────\n   1 │ Patient1  foo         foo1\n   2 │ Patient1  foo         foo2\n   3 │ Patient1  foo         foo3\n   4 │ Patient2  foo         foo4\n   5 │ Patient2  foo         foo5\n   6 │ Patient2  foo         foo6\n   7 │ Patient2  bar         bar1\n   8 │ Patient2  bar         bar2\n\njulia> filtersamplemap(samplemap(x); experiments = \"foo\")\n10×3 DataFrame\n Row │ sample    experiment  colname \n     │ String    String      String  \n─────┼───────────────────────────────\n   1 │ Patient1  foo         foo1\n   2 │ Patient1  foo         foo2\n   3 │ Patient1  foo         foo3\n   4 │ Patient2  foo         foo4\n   5 │ Patient2  foo         foo5\n   6 │ Patient2  foo         foo6\n   7 │ Patient3  foo         foo7\n   8 │ Patient3  foo         foo8\n   9 │ Patient3  foo         foo9\n  10 │ Patient4  foo         foo10\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"dropunused!(x::MultiAssayExperiment)","category":"page"},{"location":"#MultiAssayExperiments.dropunused!-Tuple{MultiAssayExperiment}","page":"Home","title":"MultiAssayExperiments.dropunused!","text":"dropunused!(x; samples = true, experiments = true, colnames = true, mapping = true)\n\nDrop unused samples, experiments and/or column names from the MultiAssayExperiment x. A reference to the modified x is returned.\n\nIf samples = true, sampledata(x) is filtered to only retain samples that are present in the sample mapping.\n\nIf experiments = true, experiments(x) is filtered to only retain experiments that are present in the sample mapping.\n\nIf colnames = true, each entry of experiments(x) is filtered to only retain column names that are present in the sample mapping for that experiment.\n\nIf mapping = true, the sample mapping is filtered to remove rows that contain samples, experiments or column names that do not exist in x.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> filtersamplemap!(x; experiments = \"bar\"); # Only keeping experiment 'bar'\n\njulia> dropunused!(x) # We see that 'foo' is dropped\nMultiAssayExperiment object\n  experiments(1): bar\n  sampledata(2): name disease\n  metadata(1): version\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"dropunused(x::MultiAssayExperiment)","category":"page"},{"location":"#MultiAssayExperiments.dropunused-Tuple{MultiAssayExperiment}","page":"Home","title":"MultiAssayExperiments.dropunused","text":"dropunused(x; kwargs...)\n\nReturn a new MultiAssayExperiment where unused samples, experiments or column names are removed. This makes a copy of x and passes it (and any keyword arguments in kwargs) to dropunused!; see the latter function for more details.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> y = filtersamplemap(x; experiments = \"bar\"); # Only keeping experiment 'bar'\n\njulia> dropunused(y) # We see that 'foo' is dropped\nMultiAssayExperiment object\n  experiments(1): bar\n  sampledata(2): name disease\n  metadata(1): version\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"multifilter!(x::MultiAssayExperiment)","category":"page"},{"location":"#MultiAssayExperiments.multifilter!-Tuple{MultiAssayExperiment}","page":"Home","title":"MultiAssayExperiments.multifilter!","text":"multifilter!(x; samples = nothing, experiments = nothing, colnames = nothing)\n\nFilters the MultiAssayExperiment x in place so that it only contains the specified samples, experiments or column names. This returns a reference to the modified x.\n\nSee filtersamplemap for the accepted values of samples, experiments and colnames. The behavior of this function is equivalent to calling filtersamplemap! followed by dropunused!.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> multifilter!(x; samples = [\"Patient2\", \"Patient3\"], experiments = \"foo\")\nMultiAssayExperiment object\n  experiments(1): foo\n  sampledata(2): name disease\n  metadata(1): version\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"multifilter(x::MultiAssayExperiment)","category":"page"},{"location":"#MultiAssayExperiments.multifilter-Tuple{MultiAssayExperiment}","page":"Home","title":"MultiAssayExperiments.multifilter","text":"multifilter!(x; samples = nothing, experiments = nothing, colnames = nothing)\n\nReturn a new MultiAssayExperiment that has been filtered to only the specified samples, experiments or column names. This makes a copy of x and passes it (and any keyword arguments in kwargs) to multifilter!; see the latter function for more details.\n\nExamples\n\njulia> using MultiAssayExperiments\n\njulia> x = exampleobject();\n\njulia> multifilter(x; samples = [\"Patient2\", \"Patient3\"], experiments = \"foo\")\nMultiAssayExperiment object\n  experiments(1): foo\n  sampledata(2): name disease\n  metadata(1): version\n\n\n\n\n\n","category":"method"},{"location":"#Miscellaneous","page":"Home","title":"Miscellaneous","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Base.copy(x::MultiAssayExperiment)","category":"page"},{"location":"#Base.copy-Tuple{MultiAssayExperiment}","page":"Home","title":"Base.copy","text":"copy(x::MultiAssayExperiment)\n\nReturn a copy of x, where all components are identically-same as those in x.\n\nExamples\n\njulia> using MultiAssayExperiments, DataFrames\n\njulia> x = exampleobject();\n\njulia> x2 = copy(x);\n\njulia> setsampledata!(x2, DataFrame(name=[\"A\", \"B\"]));\n\njulia> size(sampledata(x))\n(5, 2)\n\njulia> size(sampledata(x2)) # Change to reference is only reflected in x2.\n(2, 1)\n\njulia> stuff = experiments(x);\n\njulia> delete!(stuff, \"bar\");\n\njulia> collect(keys(experiments(x2)))\n1-element Vector{String}:\n \"foo\"\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"Base.deepcopy(x::MultiAssayExperiment)","category":"page"},{"location":"#Base.deepcopy-Tuple{MultiAssayExperiment}","page":"Home","title":"Base.deepcopy","text":"deepcopy(x::MultiAssayExperiment)\n\nReturn a deep copy of x and all of its components.\n\nExamples\n\njulia> using MultiAssayExperiments, DataFrames\n\njulia> x = exampleobject();\n\njulia> x2 = deepcopy(x);\n\njulia> insertcols!(sampledata(x), 2, \"WHEE\" => 1:5); # References now point to different objects.\n\njulia> names(sampledata(x2))\n2-element Vector{String}:\n \"name\"\n \"disease\"\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"Base.show(io::IO, x::MultiAssayExperiment)","category":"page"},{"location":"#Base.show-Tuple{IO, MultiAssayExperiment}","page":"Home","title":"Base.show","text":"print(io::IO, x::MultiAssayExperiment)\n\nPrint a summary of x.\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"expandsampledata(x::MultiAssayExperiment, exp::String)","category":"page"},{"location":"#MultiAssayExperiments.expandsampledata-Tuple{MultiAssayExperiment, String}","page":"Home","title":"MultiAssayExperiments.expandsampledata","text":"expandsampledata(x, experiment[, colnames])\n\nReturn a DataFrame containing the sample data for all or some of the column names in the chosen experiment. Columns are the same as those in sampledata(x).\n\nIf colnames is supplied, each row of the returned DataFrame corresponds to an entry of colnames and contains the data for the sample matching that column in the specified experiment.\n\nIf colnames is not supplied, each row of the returned DataFrame corresponds to a column of the specified experiment.\n\nAn error is raised if the requested columns do not have a matching sample in samplemap(x).  Use dropunused to remove unused columns from each experiment prior to calling this function.\n\nA warning is raised if sampledata(x) contains duplicate sample names. In such cases, data is taken from the first entry for each sample.\n\nA warning is raised if samplemap(x) contains multiple occurrences of the same experiment/colname combination with a different sample. In such cases, the first occurrence of the combination is used.\n\nExamples\n\njulia> using MultiAssayExperiments;\n\njulia> x = exampleobject();\n\njulia> expandsampledata(x, \"foo\")\n10×2 DataFrame\n Row │ name      disease \n     │ String    String  \n─────┼───────────────────\n   1 │ Patient1  good\n   2 │ Patient1  good\n   3 │ Patient1  good\n   4 │ Patient2  bad\n   5 │ Patient2  bad\n   6 │ Patient2  bad\n   7 │ Patient3  good\n   8 │ Patient3  good\n   9 │ Patient3  good\n  10 │ Patient4  bad\n\njulia> expandsampledata(x, \"foo\", [\"foo2\", \"foo1\"])\n2×2 DataFrame\n Row │ name      disease \n     │ String    String  \n─────┼───────────────────\n   1 │ Patient1  good\n   2 │ Patient1  good\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"exampleobject()","category":"page"},{"location":"#MultiAssayExperiments.exampleobject-Tuple{}","page":"Home","title":"MultiAssayExperiments.exampleobject","text":"exampleobject()\n\nCreate an example MultiAssayExperiment object.  This is to be used to improve the succinctness of examples and tests.\n\nExamples\n\njulia> using MultiAssayExperiments \n\njulia> x = exampleobject()\nMultiAssayExperiment object\n  experiments(2): foo bar\n  sampledata(2): name disease\n  metadata(1): version\n\n\n\n\n\n","category":"method"},{"location":"#Contact","page":"Home","title":"Contact","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package is maintained by Aaron Lun (@LTLA). If you have bug reports or feature requests, please post them as issues at the GitHub repository.","category":"page"}]
}
