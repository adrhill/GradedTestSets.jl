result(ts::GradedTestSet) = GradingResult(ts)

struct GradingResult
    description::String
    points_scored::Real
    points_total::Real
    all_passed::Bool
    subresults::Vector{GradingResult}
end

function GradingResult(ts::AbstractTestSet)
    # Recursively go through TestSet results:
    all_passed = _all_passed(ts)
    subresults = [GradingResult(r) for r in ts.results if r isa AbstractTestSet]

    if !isempty(subresults)
        points_scored = sum(getproperty.(subresults, :points_scored))
        points_total = sum(getproperty.(subresults, :points_total))
    else
        points_scored = 0
        points_total = 0
    end

    # Only GradedTestSets add points, and only if all tests within them passed:
    if isa(ts, GradedTestSet)
        points_total += ts.points
        all_passed && (points_scored += ts.points)
    end
    return GradingResult(
        ts.description, points_scored, points_total, all_passed, subresults
    )
end

_all_passed(::Result) = false
_all_passed(::Pass) = true
_all_passed(ts::AbstractTestSet) = all(_all_passed, ts.results)

#======================#
# Flattening utilities #
#======================#

const DEFAULT_DESCRIPTION_DELIM = " "
function flatten_result(res::GradingResult; delim=DEFAULT_DESCRIPTION_DELIM)
    ds = NamedTuple{(:description, :points_scored, :points_total),Tuple{String,Real,Real}}[]
    push_result!(ds, res, "", delim)
    return ds
end
function push_result!(ds, r::GradingResult, prefix::String, delim)
    if isempty(prefix)
        prefix = r.description
    elseif !isempty(r.description)
        prefix = join([prefix, r.description], delim)
    end
    # otherwise prefix is not modified

    if isempty(r.subresults)
        t = (description=prefix, points_scored=r.points_scored, points_total=r.points_total)
        push!(ds, t)
    else
        for sr in r.subresults
            push_result!(ds, sr, prefix, delim)
        end
    end
end

# Convenience functions:
function descriptions(r::GradingResult; delim=DEFAULT_DESCRIPTION_DELIM)
    return getfield.(flatten_result(r; delim=delim), :description)
end

# TODO: avoid code duplication by generating functions
points_scored(r::GradingResult) = getfield.(flatten_result(r), :points_scored)
points_total(r::GradingResult) = getfield.(flatten_result(r), :points_total)


function tuple_scored(r::GradingResult; delim=DEFAULT_DESCRIPTION_DELIM)
    fr = flatten_result(r; delim=delim)
    descriptions = [Symbol(r.description) for r in fr]
    points_scored = getfield.(fr, :points_scored)
    return (; zip(descriptions, points_scored)...)
end

function tuple_total(r::GradingResult; delim=DEFAULT_DESCRIPTION_DELIM)
    fr = flatten_result(r; delim=delim)
    descriptions = [Symbol(r.description) for r in fr]
    points_total = getfield.(fr, :points_total)
    return (; zip(descriptions, points_total)...)
end
