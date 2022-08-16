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
using Revise

# Local Dependencies
# ---------------------
include("Cells.jl")
using .Cells

# Module Constants
# ---------------------
const ROW_NAMES = "ABCDEFGHIJKLMNOPQRSTUVWXYZ@#\$%&"
const COL_NAMES = "abcdefghijklmnopqrstuvwxyz=+-:/"
const ACTIONS_SYMBOLS = "!*"

const MAX_ROWS = 30
const MAX_COLS = 30
const ERROR_MSGS = Dict(
    # key : error message
    "mark_limit" => "THERE CANNOT BE MORE MARKED CELLS THAN MINES",
    "open_mark" => "A MARKED CELL CANNOT BE OPENED",
    "mark_opened" => "AN OPENED CELL CANNOT BE MARKED",
    "already_opened" => "CELL ALREADY OPENED. MORE NEIGHBOUR CELLS CANNOT BE OPENED"
)

## Characters to draw the Board
const INDENT_BIG = "    "
const INDENT_SMALL = "  "
const COE = '\u2500' # ─ 
const CNS = '\u2502' # │ 
const CES = '\u250C' # ┌ 
const CSO = '\u2510' # ┐ 
const CNE = '\u2514' # └ 
const CON = '\u2518' # ┘ 
const COES = '\u252C' # ┬ 
const CNES = '\u251C' # ├ 
const CONS = '\u2524' # ┤ 
const CONE = '\u2534' # ┴ 


# Exported references
# ---------------------
export Board, Play, play!, isended, islost, iswon, rownames, colnames, actionsymbols


# Auxiliary functions 
# ---------------------
"""
    Action 

Enumeration of the two possible actions that can be applied on a cell: `mark` and `open`.
"""
@enum Action amark = 1 aopen = 2
@enum Result win = 1 loss = 2 unknown = 3

function symbol2action(s::Char)
    !(s in ACTIONS_SYMBOLS) && throw(DomainError(s, "action symbol must be '!' or '*'"))
    Action(findfirst(s, ACTIONS_SYMBOLS)[1])
end

function rowname2int(r::Char)
    !(r in ROW_NAMES) && throw(DomainError(r, "row name must be 'ABCD...'"))
    findfirst(r, ROW_NAMES)[1]
end

function colname2int(c::Char)
    !(c in COL_NAMES) && throw(DomainError(c, "colum name must be in 'abcd...'"))
    findfirst(c, COL_NAMES)[1]
end


# Main functions 
# ---------------------

"""
    Play 

Represents a play  in the game 
"""
struct Play
    row::Int
    col::Int
    action::Action
end

""" 
    Play(row::Char, col::Char, action::Char)    

Creates a Play given the row, the column and the action as Char.
"""
function Play(row::Char, col::Char, action::Char)
    Play(
        rowname2int(row),
        colname2int(col),
        symbol2action(action)
    )
end


"""
    Board 

Represents a Minesweeper gameboard with an start time `tstart`
and cells `cells`.
"""
mutable struct Board <: AbstractArray{Cell,2}
    cells::Matrix{Cell}
    tstart::Dates.DateTime
    tend::Union{Dates.DateTime,Nothing}
    result::Result

    function Board(cells::Matrix{Cell})
        new(cells, Dates.now(), nothing, Result(3))
    end
end

"""
    Board(rows::Int, cols::Int, n::Int)

Constructs a Board of size `(rows, cols)` with `n` mines randomly
located.
"""
function Board(rows::Int, cols::Int, n::Int)
    (rows >= 1) || throw(DomainError(rows, "the number of rows must be >= 1"))
    (cols >= 1) || throw(DomainError(cols, "the number of columns must be >= 1"))
    (n >= 1) || throw(DomainError(n, "the number of mines must be >= 1"))

    mined_positions = sample(1:(rows*cols), n, replace=false)
    cells = Array{Cell,2}(undef, rows, cols)

    for j = 1:cols, i = 1:rows
        pos::Int = (i - 1) * cols + j
        hasmine::Bool = pos in mined_positions
        cells[i, j] = Cell(i, j, hasmine)
    end

    Board(cells)
end

"""
    Board(rows::Int, cols::Int, n::Int)

Constructs a Board of difficulty `d` in `[:begginer, :intermediate, :expert]`.
"""
function Board(d::Symbol)
    (d in [:beginner, :intermediate, :expert]) || throw(DomainError(d, "invalid diffulty level"))

    if d == :beginner
        Board(9, 9, 10)
    elseif d == :intermediate
        Board(16, 16, 40)
    else # :expert
        Board(16, 30, 99)
    end
end

"""
    Board(rows::Int, cols::Int, n::Int)

Constructs a Board from a textfile especification.
"""
function Board(v::Vector{String})
    s = split(strip(v[1]))
    n_rows = parse(Int, s[1])
    n_cols = parse(Int, s[2])

    # create empty array of cells
    cells = Array{Cell,2}(undef, n_rows, n_cols)

    for (i, row) in enumerate(v[2:end])
        for (j, col) in enumerate(strip(row))
            hasmine = (col == '*') ? true : false
            cells[i, j] = Cell(i, j, hasmine)
        end
    end

    Board(cells)
end


"""
    getindex(b::Board, i::Int64, j::Int64)

Gets 'b.cells[i,j]'.
"""
function getindex(b::Board, i::Int64, j::Int64)::Cell
    getindex(b.cells, i, j)
end

"""
    size(b::Board)

Dimensions of the Board `b`.
"""
function size(b::Board)::Tuple{Int, Int}
    size(b.cells)
end

"""
    show(io::IO, b::Board)

Writes a text representation of the board.
"""
function show(io::IO, b::Board)

    # Auxiliar functions
    function rowindent(row::Int)
        iseven(row) ? " " : "   "
    end

    n_rows, n_cols = size(b)
    t_sec = Dates.format(boardtime(b), "S.s") # time in seconds


    # header
    s = "\nREMAINING MINES: $(nmined(b) - nmarked(b)) | MARKED: $(nmarked(b)) | TIME: $(t_sec) sec.\n"

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
                        row *= "$(ROW_NAMES[i])$(rowindent(i))$(CNS) $(tochar(b[i,j])) "
                    elseif 1 < j < n_cols
                        row *= "$(CNS) $(tochar(b[i,j])) "
                    else
                        row *= "$(CNS) $(tochar(b[i,j])) $(CNS)\n"
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
    isended(b::Board)

Determines if the game has ended
"""

function isended(b::Board)::Bool
    b.tend !== nothing
end

"""
    iswon(b::Board)

Determines if the game has been won
"""
function iswon(b::Board)::Bool
    b.result == Result.win
end

"""
    islost(b::Board)

Determines if the game has been lost
"""
function islost(b::Board)::Bool
    b.result == Result.loss 
end 

"""
    play(board::Board, p::Play)

"""
function play!(b::Board, p::Play)

    cell = b[p.row, p.col]

    # validate play 
    if p.action == amark && (nmarked(b) == nmined(b))
        throw(ErrorException(ERROR_MSGS["mark_limit"]))
    end
    if p.action == amark && isopen_(cell)
        throw(ErrorException(ERROR_MSGS["mark_opened"]))
    end
    if p.action == aopen && ismarked_(cell)
        throw(ErrorException(ERROR_MSGS["open_mark"]))
    end
    if p.action == aopen && isopen_(cell) && n(neighbours(b, p.row, p.col)) > 0
        throw(ErrorException(ERROR_MSGS["already_opened"]))
    end

    # mark
    if p.action == amark
        mark!(cell)
        if allmarked(b)
            registerwin!(b)
        end
        # open 
    else
        # queue containing the cellls to be opened
        queue::Vector{Cell} = [cell]

        while !isempty(queue) && !isended(b)
            c = pop!(queue)

            if !isopen_(c)
                open!(c)
                if hasmine(c)
                    registerloss!(b)
                end
            else
                nbs = neighbours(b, c.row, c.col)
                if n(nbs) <= 0
                    unmarked_nbs = filter(nb -> !ismarked_(nb), nbs)
                    append!(queue, unmarked_nbs)
                end
            end
        end
    end

end

"""
    boardtime(b::Board)
Determines the elapsed time since the Board `b` was created.
"""
function boardtime(b::Board)
    convert(Dates.DateTime, Dates.now() - b.tstart)
end

"""
    nmarked(b::Board)

Number of cells that are marked 
"""
function nmarked(b::Board)::Int
    marked = 0
    n_rows, n_cols = size(b)

    for j = 1:n_cols, i = 1:n_rows
        ismarked_(b[i, j]) && (marked += 1)
    end

    marked
end

"""
    nmined(b::Board)

Number of cells that are mined 
"""
function nmined(b::Board)::Int
    mined = 0
    n_rows, n_cols = size(b)

    for j = 1:n_cols, i = 1:n_rows
        hasmine(b[i, j]) && (mined += 1)
    end
    mined
end

"""
    neighbours(b::Board, i::Int64, j::Int64)

Cell neighbours at position `[i, j]`
"""
function neighbours(b::Board, i::Int64, j::Int64)::Vector{Cell}
    nbs::Vector{Cell} = []
    n_rows, n_cols = size(b)

    if j > 1
        append!(nbs, b[i, j-1])
    end

    if j < n_cols
        append!(nbs, b[i, j+1])
    end

    if isodd(i)
        if i > 1
            append!(nbs, [b[i-1, j], b[i-1, j+1]])
        end

        if i < n_rows
            append!(nbs, [b[i+1, j], b[i+1, j+1]])
        end
    else
        if i > 1
            append!(nbs, [b[i-1, j], b[i-1, j-1]])
        end

        if i < n_rows
            append!(nbs, [b[i+1, j], b[i+1, j-1]])
        end
    end
    nbs
end

"""
    n(n::Vector{Cell})

Estimated number of mines to be discovered among a group of cells.
"""
function n(cells::Vector{Cell})::Int
    withmine = length(filter(c -> hasmine(c), cells))
    withmark = length(filter(c -> ismarked_(c), cells))

    withmine - withmark
end

"""
    actionsymbols(b::Board)

Column names of a Board `b`.
"""
function actionsymbols(b::Board)::String
    ACTIONS_SYMBOLS
end

"""
    colnames(b::Board)

Column names of a Board `b`.
"""
function colnames(b::Board)::String
    n_cols = size(b)[2]
    COL_NAMES[1:n_cols]
end

"""
    rownames(b::Board)

Row names of a Board `b`.
"""
function rownames(b::Board)::String
    n_rows = size(b)[1]
    ROW_NAMES[1:n_rows]
end

"""
    allmarked(b::Board)

Determines if the game has been lost
"""
function allmarked(b::Board)::Bool
    n_rows, n_cols = size(b)

    for j = 1:n_cols, i = 1:n_rows
        if !isopen_(b[i, j]) && !ismarked_(b[i, j])
            return false
        end
    end
    true
end

"""
    openall!(b::Board)

Opens all cells of the Board.
"""
function openall!(b::Board)
    n_rows, n_cols = size(b)

    for j = 1:n_cols, i = 1:n_rows
        open!(b[j,i])
    end 
end 

"""
    registerwin!(b::Board)

Registers that the user has won the game on the Board.
"""
function registerwin!(b::Board)
    b.result = Result.win
    registerend!(b)
end

"""
    registerloss!(b::Board)

Registers that the user has lost the game on the Board.
"""
function registerloss!(b::Board)
    b.result = Result.loss
    registerend!(b)
end

"""
    registerend!(b::Board)

Registers that the the current time as the end time
"""
function registerend!(b::Board)
    b.tend = Dates.now()
end

end # module    
