using GradedTestSets
using Test

@testset "GradedTestSets.jl" begin
    t1 = @testset GradedTestSet "Hw0" begin
        @testset points = 1 "Ex1" begin
            @test true
            @testset points = 2 "a" begin
                @test true
                @test true
            end
        end
        @testset "Ex2" begin
            @testset points = 3 "a" begin
                @test true
                @test false
            end
            @testset points = 2 "b" begin
                @test true
                @test true
            end
        end
    end

    @testset "GradingResult" begin
        r1 = result(t1)
        @test r1.points_scored == 5
        @test r1.points_total == 8

        @test descriptions(r1) == ["Hw0 Ex1 a", "Hw0 Ex2 a", "Hw0 Ex2 b"]
        @test descriptions(r1; delim="") == [  "Hw0Ex1a","Hw0Ex2a", "Hw0Ex2b"]

        @test points_scored(r1) == [2, 0, 2]
        @test points_total(r1) == [2, 3, 2]

        @test tuple_scored(r1; delim="") == (Hw0Ex1a = 2, Hw0Ex2a = 0, Hw0Ex2b = 2)
        @test tuple_total(r1; delim="") == (Hw0Ex1a = 2, Hw0Ex2a = 3, Hw0Ex2b = 2)
    end
end
