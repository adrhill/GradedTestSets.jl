module GradedTestSets
import Test: Test, record, finish
using Test: AbstractTestSet, Result, Pass, Fail, Error
using Test: get_testset_depth, get_testset

# Points are given if all tests within a GradedTestSet pass.
# You might therefore want to only assign points to "leaf-test-sets".

mutable struct GradedTestSet <: AbstractTestSet
    description::String
    points::Real # points scored if all sub-tests pass
    results::Vector{Any}
end
GradedTestSet(desc; points=0) = GradedTestSet(desc, points, [])

record(ts::GradedTestSet, res::Result) = push!(ts.results, res)
record(ts::GradedTestSet, child::AbstractTestSet) = push!(ts.results, child)
function finish(ts::GradedTestSet)
    # Record self to parent if we're not the top-level parent
    if get_testset_depth() != 0
        parent_ts = get_testset()
        record(parent_ts, ts)
        return ts
    end
    ts
end

include("results.jl")
include("show.jl")

export GradedTestSet
export result, GradingResult
export flatten_result, descriptions, points_scored, points_total, tuple_scored, tuple_total
end # module
