# Test of Cells.jl

@testset "cell.jl" begin

mine = true
cell = Cell(1,1, mine)

# Constructor
@test cell.col == 1 
@test cell.row == 1 
@test hasmine(cell) == mine 
@test isopen_(cell) == false
@test ismarked_(cell) == false 

# open!
open!(cell) 
@test isopen_(cell) == true 
open!(cell)
@test isopen_(cell) == true 

# mark! 
mark!(cell)
@test ismarked_(cell) == true 
mark!(cell)
@test ismarked_(cell) == false 



end # @testset