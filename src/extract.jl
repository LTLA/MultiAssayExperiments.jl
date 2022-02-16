function extractsampledata(x::MultiAssayExperiment, experiment::String, colnames::Vector{String})
    sm = samplemap(x)
    collated = Dict{String,String}()
    for r in eachrow(sm)
        if r.experiment == experiment
            collated[r.colname] = r.sample
        end
    end

    samples = Dict{String,Int}()
    sd = sampledata(x)
    sn = sd[!,"name"]
    for s in 1:length(sn)
        sample = sn[s]
        if haskey(samples, sample)
            @warn "multiple rows in 'sampledata(x)' for '" * sample * "', using the first only"
            continue
        end
        samples[sample] = s
    end

    indices = Vector{Int}(undef, length(colnames))
    for c in 1:length(colnames)
        colname = colnames[c]
        if !haskey(collated, colname)
            throw(ErrorException("failed to find column name '" * colname * "' in the sample mapping for experiment '" * experiment * "'"))
        end

        x = collated[colname];
        if !haskey(samples, x)
            throw(ErrorException("failed to find sample name '" * x * "' in the sample data"))
        end

        indices[c] = samples[x]
    end

    return sd[indices,:]
end
