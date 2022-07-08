"""
    Boards

Includes the Board struct and all its related functionality.
"""
module Boards

# Base Dependencies 
# ---------------------
import Base: size, show, getindex
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
ACTIONS = "!*"
MAX_ROWS = 30
MAX_COLS = 30

## Characters to draw the Board
INDENT_BIG = "    "
INDENT_SMALL = "  "
COE = '\u2500' # ─ 
CNS = '\u2502' # │ 
CES = '\u250C' # ┌ 
CSO = '\u2510' # ┐ 
CNE = '\u2514' # └ 
CON = '\u2518' # ┘ 
COES = '\u252C' # ┬ 
CNES = '\u251C' # ├ 
CONS = '\u2524' # ┤ 
CONE = '\u2534' # ┴ 


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
mutable struct Board <: AbstractArray{Cells.Cell, 2}
    cells::Matrix{Cells.Cell}
    tstart::Dates.DateTime
    tend::Union{Dates.DateTime,Nothing}  
    
    function Board(cells::Matrix{Cells.Cell})
        new(cells, Dates.now(), nothing)
    end
end

"""
    Board(rows::Int, cols::Int, n::Int)

Constructs a Board of size `(rows, cols)` with `n` mines randomly
located.
"""
function Board(rows::Int, cols::Int, n::Int)

    mined_positions = sample(1:(rows*cols), n, replace=false)
    cells = Array{Cells.Cell,2}(undef, rows, cols)

    for j in 1:cols
        for i in 1:rows
            pos::Int = (i - 1) * cols + j
            hasmine::Bool = pos in mined_positions
            cells[i, j] = Cells.Cell(hasmine)
        end
    end

    Board(cells)
end

"""
    Board(rows::Int, cols::Int, n::Int)

Constructs a Board of difficulty `d` in `[:begginer, :intermediate, :difficult]`.
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
    Board(rows::Int, cols::Int, n::Int)

Constructs a Board from a text especification.
"""
function Board(v::Vector{String})
    s = split(strip(v[1]))
    n_rows = parse(Int, s[1])
    n_cols = parse(Int, s[2])

    # create empty array of cells
    cells = Array{Cells.Cell, 2}(undef, n_rows, n_cols)
    
    for (i, row) in enumerate(v[2:end])
        for (j, c) in enumerate(strip(row))
            hasmine = c == '*' ? true : false
            cells[i,j] = Cells.Cell(hasmine)
        end
    end

    Board(cells)
end 


"""
    getindex(b::Board, i::Int64, j::Int64)

Gets 'b.cells[i,j]'.
"""
function getindex(b::Board, i::Int64, j::Int64)
    getindex(b.cells, i, j)
end

"""
    size(b::Board)

Dimensions of the Board `b`.
"""
function size(b::Board)
    size(b.cells)
end

"""
    show(io::IO, b::Board)

Writes a text representation of the board.
"""
function show(io::IO, b::Board)

    # Auxiliar functions
    rowindent(row::Int) = iseven(row) ?  " " : "   "

    n_rows, n_cols = size(b)
    t_sec = Dates.format(boardtime(b), "S.s") # time in seconds

    # header
    s = "\nREMAINING MINES: $(16) | MARKED: $(marked(b)) | TIME: $(t_sec) sec.\n"

    # col names 
    colnames = "     "
    for letter in COL_NAMES[1:n_cols]
        colnames *= "$(letter)   "
    end
    s = s * colnames * "\n"

    # rows 
    for i = 1:n_rows
        row = ""
        for k = 1:3
            for j = 1:n_cols
                if k == 1
                    if j == 1
                        if i == 1
                            row *= "$(INDENT_BIG)$(CES)$(COE)$(COE)$(COE)"
                        elseif isodd(i)
                            row *= "$(INDENT_SMALL)$(CNE)$(COE)$(COES)$(COE)$(CONE)$(COE)"
                        else
                            row *= "$(INDENT_SMALL)$(CES)$(COE)$(CONE)$(COE)"
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
                            row *= "$(COES)$(COE)$(COE)$(COE)$(CSO)\n"
                        elseif isodd(i)
                            row *= "$(COES)$(COE)$(CONE)$(COE)$(CSO)\n"
                        else
                            row *= "$(COES)$(COE)$(CONE)$(COE)$(COES)$(COE)$(CON)\n"
                        end
                    end

                elseif k == 2
                    if j == 1
                        row *= "$(ROW_NAMES[i])$(rowindent(i))$(CNS) $(Cells.tochar(b[i,j])) "
                    elseif 1 < j < n_cols
                        row *= "$(CNS) $(Cells.tochar(b[i,j])) "
                    else
                        row *= "$(CNS) $(Cells.tochar(b[i,j])) $(CNS)\n"
                    end

                else
                    if j == 1 && i == n_rows
                        if isodd(i)
                            row *= "$(INDENT_BIG)$(CNE)$(COE)$(COE)$(COE)"
                        else
                            row *= "$(INDENT_SMALL)$(CNE)$(COE)$(COE)$(COE)"
                        end 
                    elseif 1 < j < n_cols && i == n_rows
                        row *= "$(CONE)$(COE)$(COE)$(COE)"
                    elseif j == n_cols && i == n_rows
                        row *= "$(CONE)$(COE)$(COE)$(COE)$(CON)\n"
                    else
                        continue
                    end
                end      
            end # k for
        end # j for
        s *= row
    end # i for

    print(io, s)
end

"""
    boardtime(b::Board)
Determines the elapsed time since the Board `b` was created.
"""
function boardtime(b::Board)
    convert(Dates.DateTime, Dates.now() - b.tstart)
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
            if b.cells[i, j].marked
                marked += 1
            end
        end
    end

    marked
end

"""
    neighbours(b::Board, i::Int64, j::Int64)

Cell neighbours at position `[i, j]`
"""
function neighbours(b::Board, i::Int64, j::Int64)
    n::Vector{Cells.Cell} = []
    n_rows, n_cols = size(b)

    if j > 1
        append!(n, b[i,j-1])
    end

    if j < n_cols
        append!(n, b[i,j+1])
    end

    if isodd(i)
        if i > 1
            append!(n, [b[i-1, j], b[i-1,j+1]])
        end 

        if i < n_rows
            append!(n, [b[i+1,j], b[i+1,j+1]])
        end 
    else
        if i > 1
            append!(n, [b[i-1, j], b[i-1,j-1]])
        end 

        if i < n_rows
            append!(n, [b[i+1,j], b[i+1,j-1]])
        end 

    end
    n
end 

"""
    n(n::Vector{Cell})

Estimated number of mines to be discovered among the neighbours
of Cell at position `[i,j]`.
"""
function n(b::Board, i::Int64, j::Int64)
    nbs = neighbours(b, i, j)
    withmine = length(filter(c -> hasmine(c), nbs))
    withmark = length(filter(c -> ismarked(c), nbs))

    withmine - withmark
end 

function colnames(b::Board)
    n_rows, n_cols = size(b)
    COL_NAMES[1:n_cols]
end

function rownames(b::Board)
    n_rows, n_cols = size(b)
    ROW_NAMES[1:n_rows]
end

function isfinished(b::Board)
    #TODO
    false
end 


function isvalid_play(b::Board, play::String)
    if length(play) != 3 
        falseñ
    elseif !(play[1] in rownames(b))
        false 
    elseif !(play[2] in colnames(b))
        false
    elseif !(play[3] in ACTIONS)
        false
    else
        true 
    end
end


function regfinish!(b::Board)
    b.tend = Dates.now()
end

function mark!(b::Board, i::Int64, j::Int64)
    Cells.mark!(b[i,j])
end

function open!(b::Board, i::Int64, j::Int64)
    Cells.open!(b[i,j])
end 

end # module    
