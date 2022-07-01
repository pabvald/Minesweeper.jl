"""
    Boards

Includes the Board struct and all its related functionality.
"""
module Boards

# Base Dependencies 
# ---------------------
import Base: size
import StatsBase: sample

# 3rd Party Dependencies 
# ---------------------
using Dates 

# Inclusions
# ---------------------
include("Cells.jl")

# Module Constants
# ---------------------
ROW_NAMES = "ABCDEFGHIJKLMNOPQRSTUVWXYZ@#\$%&"
COL_NAMES = "abcdefghijklmnopqrstuvwxyz=+-:/"
MAX_ROWS = 30
MAX_COLS = 30

## Characters to draw the Board
COE  = '\u2500' # ─ 
CNS  = '\u2502' # │ 
CES  = '\u250C' # ┌ 
CSO  = '\u2510' # ┐ 
CNE  = '\u2514' # └ 
CON  = '\u2518' # ┘ 
COES = '\u252C' # ┬ 
CNES = '\u251C' # ├ 
CONS = '\u2524' # ┤ 
CONE = '\u2534' # ┴ 
CSOM = '\u2593' # ▒


# Exported references
# ---------------------
export Board


# Main functions 
# ---------------------
"""
    Board 

Represents a Minesweeper gameboard with an start time `tstart`
and cells `cells`.
"""
mutable struct Board
    tstart::Dates.DateTime
    tend::Union{Dates.DateTime, Nothing}
    cells::Matrix{Cells.Cell}
end

"""
    Board

Constructs a Board with a start time `Dates.now()` and cells `cells`.
"""
Board(cells::Matrix{Cells.Cell}) = Board(Dates.now(), nothing, cells)


"""
    Board 

Constructs a Board of dimensions `(rows, cols)` with `n` mines 
randomly distributed.
"""
function Board(rows::Int, cols::Int, n::Int)

    mined_positions = sample(1:(rows*cols), n, replace=false)
    cells = Array{Cells.Cell, 2}(undef, rows, cols)
    
    for j in 1:cols
        for i in 1:rows 
            pos::Int = (i-1)*cols + j
            hasmine::Bool = pos in mined_positions
            c = Cells.Cell(hasmine)
            cells[i,j] = c
        end 
    end  
    
    Board(cells)
end


"""
    Board

Constructs a Board with difficulty `d`.
"""
function Board(d::Symbol)
    if d == :beginner
        Board(9, 9, 10)
    elseif d == :intermediate
        Board(16, 16, 40)
    elseif d == :expert 
        Board(16, 30, 99)
    else
        throw(ArgumentError("undefined difficulty '$(:d)'"))
    end 
end

"""
    Board

Constructs a Board from a string definition.
"""
function Board(board::String)
    return undef 
end

"""
    size(b::Board)

Dimensions of the Board `b`.
"""
function size(b::Board)
    size(b.cells)
end 


end # module    


