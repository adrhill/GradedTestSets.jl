using GradedTestSets
using Test

@testset "GradedTestSets.jl" begin
    t1 = @testset GradedTestSet "Homework 1" begin
        @testset points = 1 "Task 1" begin
            @test true
            @testset points = 2 "a)" begin
                @test true
                @test true
            end
        end
        @testset "Task 2" begin
            @testset points = 3 "a)" begin
                @test true
                @test false
            end
            @testset points = 2 "b)" begin
                @test true
                @test true
            end
        end
    end

    @testset "GradingResult" begin
        r1 = result(t1)
        @test r1.points_scored == 5
        @test r1.points_total == 8

        @test descriptions(r1) == [
            "Homework 1 - Task 1 - a)",
            "Homework 1 - Task 2 - a)",
            "Homework 1 - Task 2 - b)",
        ]
        @test descriptions(r1; delim=".") ==
            ["Homework 1.Task 1.a)", "Homework 1.Task 2.a)", "Homework 1.Task 2.b)"]

        @test points_scored(r1) == [2, 0, 2]
        @test points_total(r1) == [2, 3, 2]
    end
end
