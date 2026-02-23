# GradedTestSets.jl

[![Build Status](https://github.com/adrhill/GradedTestSets.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/adrhill/GradedTestSets.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/adrhill/GradedTestSets.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/adrhill/GradedTestSets.jl)

A Julia package that extends `Test.jl` with graded test sets for automatic scoring of assignments.

## Installation

```julia
using Pkg
Pkg.add("GradedTestSets")
```

## Usage

`GradedTestSet` is a custom `AbstractTestSet` that assigns points to test sets.
Points are awarded when all tests within a `GradedTestSet` pass.

```julia
using GradedTestSets
using Test

ts = @testset GradedTestSet "Homework 1" begin
    @testset points = 2 "Exercise 1" begin
        @test 1 + 1 == 2
        @test 2 * 3 == 6
    end
    @testset points = 3 "Exercise 2" begin
        @test sin(0) == 0
        @test cos(0) == 1
    end
end
```

### Accessing Results

Use `result` to obtain a `GradingResult` from a `GradedTestSet`:

```julia
r = result(ts)
r.points_scored  # total points scored
r.points_total   # total points available
```

### Flattening and Extracting Data

```julia
flatten_result(r)              # vector of (description, points_scored, points_total) named tuples
descriptions(r)                # vector of leaf test set descriptions
points_scored(r)               # vector of scored points per leaf test set
points_total(r)                # vector of total points per leaf test set

tuple_scored(r; delim="")      # named tuple mapping descriptions to scored points
tuple_total(r; delim="")       # named tuple mapping descriptions to total points
```
