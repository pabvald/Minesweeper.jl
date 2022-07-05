"""
    Boards

Includes the Board struct and all its related functionality.
"""
module Boards

# Base Dependencies 
# ---------------------
import Base: size, show
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
INDENT_BIG = "    "
INDENT_SMALL = "  "
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


# Auxiliary functions 
# ---------------------



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
    boardtime(b::Board)
Determines the elapsed time since the Board `b` was created.
"""
function boardtime(b::Board)
    convert(Dates.DateTime, Dates.now() - b.tstart)
end


function show(io::IO, b::Board)

    rowindent(row::Int) = " " ? iseven(row) : "   "
    n_rows, n_cols = size(b)
    t_sec = Dates.format(boardtime(b), "S.s") # time in seconds

    # header
    s = "REMAINING MINES: $(16) | MARKED: $(3) | TIME: $(t_sec) sec.\n"

    # col names 
    colnames = "     "
    for letter in COL_NAMES[1:n_cols]
        colnames *= "$(letter)   " 
    end  
    s = s * colnames * "\n"
    
    # rows 
    for i in 1:n_rows
        row = ""
        for k in 1:3
            for j in 1:n_cols         
                if k == 1
                    if j == 1 
                        if i == 1 
                            row *= "    $(CES)$(COE)$(COE)$(COE)"
                        elseif isodd(i)
                            row *= "  $(CNE)$(COE)$(COES)$(COE)$(CONE)$(COE)"
                        else 
                            row *= "  $(CES)$(COE)$(CONE)$(COE)"
                        end 
                    elseif (1 < j < n_cols)
                        if i == 1 
                            row *= "$(COES)$(COE)$(COE)$(COE)"
                        elseif isodd(i)
                            row *= "$(COES)$(COE)$(CONE)$(COE)"
                        else
                            row *= "$(COES)$(COE)$(CONE)$(COE)"
                        end 
                    else  # j == n_cols 
                        if i == 1 
                            row *=  "$(COES)$(COE)$(COE)$(COE)$(CSO)\n"
                        elseif isodd(i)
                            row *= "$(COES)$(COE)$(CONE)$(COE)$(CSO)\n"
                        else 
                            row *= "$(COES)$(COE)$(CONE)$(COE)$(COES)$(COE)$(CON)\n"
                        end 
                    end 

                elseif k == 2 
                    if  j== 1 
                        row *= "$(ROW_NAMES[i])$(rowindent(i))$(CNS) $(CSOM) "
                    elseif 1 < j < n_cols
                        row *= "$(CNS) $(CSOM) "
                    else 
                        row *= "$(CNS) $(CSOM) $(CNS)\n"
                    end 

                else
                    if j == 1 && i == n_rows
                        row *= "    $(CNE)$(COE)$(COE)$(COE)"
                    elseif 1 < j < n_cols && i == n_rows
                        row *= "$(CONE)$(COE)$(COE)$(COE)"
                    elseif j == n_cols && i == n_rows
                        row *= "$(CONE)$(COE)$(COE)$(COE)$(CON)\n"
                    else 
                        continue
                    end  
                end                
            end  # k for        
        end 
        s *= row
    end 
    print(io, s)
end

"""
    size(b::Board)

Dimensions of the Board `b`.
"""
function size(b::Board)
    size(b.cells)
end 


"""
    marked(b::Board)

Number of cells that are marked 
"""
function marked(b::Board)
    n_rows, n_cols = size(b)

    marked = 0
    for j in 1:n_cols
        for i in 1:n_rows 
            if b.cells[i,j].marked 
                marked += 1
            end 
        end 
    end 
    
    marked
end

end # module    


