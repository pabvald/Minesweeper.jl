using Test 

# Includes 
# -----------------------------------
include("../src/Boards.jl")
include("../src/Cells.jl")

# Local Dependencies
# ----------------------------------
using .Boards 
using .Cells

println("Julia version: ", VERSION)

function run_tests(list)
    for test in list
        println("TEST: $test \n")
        include(test)
        println("=" ^ 50)
    end
end


test_sets = [
    ("Board", ["board.jl"]),
    ("Cell", ["cell.jl"])
]

@testset "Test Suites" begin
    for ts in eachindex(test_sets)
        name = test_sets[ts][1]
        list = test_sets[ts][2]
        let
            @testset "$name" begin
                run_tests(list)
            end
        end
    end
end