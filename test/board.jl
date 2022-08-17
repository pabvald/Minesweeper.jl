# Test of Boards.jl

@testset "board.jl" begin 


# board loading
board_txt::Vector{String} = readlines("src/data/board1.txt")
board = Board(board_txt)

@test size(board) == (9, 10)
@test Boards.nmined(board) == 19

# neighbours
cc = [(1,1), (3,5), (4,6), (5, 1), (7,10)]
nbs_indexes = [
    [(1,2), (2,2), (2,1)],
    [(3,4), (3,6), (2,5), (2,6), (4,5), (4,6)],
    [(4,5), (4,7), (3,5), (3,6), (5,5), (5,6)],   
    [(4,1), (4,2), (5,2), (6,2), (6,1)],
    [(6,10), (7,9), (8,10)]
]

for (c, idx) in zip(cc, nbs_indexes)
    nbs = neighbours(board, c[1], c[2])
    @test length(nbs) == length(idx)
    for nb in nbs  
        @test ((nb.row, nb.col) in idx)
    end 
end 

# n = nmined - nmarked
@test n(neighbours(board, 1, 9)) == 1
@test n(neighbours(board, 9, 9)) == 2
@test n(neigbours(board, 3, 2)) == 6

end 