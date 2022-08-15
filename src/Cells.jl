"""
    Cells

Includes the Cell struct and all its related functionality. 
"""
module Cells

# Base Dependencies
# ---------------------

# Exported references
# ---------------------
export Cell, open!, mark!, tochar, isopen, ismarked

# Constants 
# ---------------------

# Main functions
# ---------------------

"""
    Cell 

Cell of the board.
"""
mutable struct Cell
    row::Int
    col::Int 
    opened::Bool
    marked::Bool 
    mined::Bool
    
    function Cell(row, col, hasmine) 
        new(row, col, false, false, hasmine)
    end
end 

"""
    open!(c::Cell)

Opens a Cell c. If the Cell is already open, it has no effect.
"""
function open!(c::Cell)
    c.opened = true
end 

"""
    mark!(c::Cell)

Marks a Cell c if it is unmarked, it unmarks it otherwise.
"""
function mark!(c::Cell)
    c.marked = !c.marked
end 

"""
    isopen(c::Cell)
Returns `true` if Cell `c` is 'opened'.
"""
function isopen(c::Cell)::Bool
    c.opened
end

"""
    isopen(c::Cell)
Returns `true` if Cell `c` is 'opened'.
"""
function ismarked(c::Cell)::Bool
    c.marked
end

"""
    hasmine(c::Cell)
Returns `true` if Cell `c` is 'mined'.
"""
function hasmine(c::Cell)::Bool
    c.hasmine
end 

"""
    tochar(c::Cell, n::Int=0)

Provides a character representation of a Cell `c` depending on 
its state and the `n = # of mined neighbours - # of marked neighbours`.
""" 
function tochar(c::Cell, n::Int=0)::Char
    #TODO special cases when the game has finished
    if isopen(c)
        if n < 0 
            '?'
        elseif n == 0
            ' '
        else # n > 0
            Char(n)
        end 
    else
        if ismarked(c)
            'X'
        else 
            '\u2593' # ▒
        end 
    end     
end

end 
