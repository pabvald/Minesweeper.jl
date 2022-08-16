"""
    Cells

Includes the Cell struct and all its related functionality. 
"""
module Cells

# Base Dependencies
# ---------------------

# Exported references
# ---------------------
export Cell, open!, mark!, tochar, isopen_, ismarked_, hasmine

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
    open::Bool
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
    c.open = true
end 

"""
    mark!(c::Cell)

Marks a Cell c if it is unmarked, it unmarks it otherwise.
"""
function mark!(c::Cell)
    c.marked = !c.marked
end 

"""
    isopen_(c::Cell)
Returns `true` if Cell `c` is 'open'.
"""
function isopen_(c::Cell)::Bool
    c.open
end

"""
    ismarked_(c::Cell)
Returns `true` if Cell `c` is 'marked'.
"""
function ismarked_(c::Cell)::Bool
    c.marked
end

"""
    hasmine(c::Cell)
Returns `true` if Cell `c` is 'mined'.
"""
function hasmine(c::Cell)::Bool
    c.mined
end 

"""
    tochar(c::Cell, n::Int=0)

Provides a character representation of a Cell `c` depending on 
its state and the `n = # of mined neighbours - # of marked neighbours`.
""" 
function tochar(c::Cell, n::Int, finished::Bool)::Char
    if finished
        if ismarked_(c) && !hasmine(c)
            '#'
        elseif !ismarked_(c) && hasmine(c)
            '*'
        else
            ' '
        end 
    else 
        if isopen_(c)
            if n < 0 
                '?'
            elseif n == 0
                ' '
            else # n > 0
                Char(n)
            end 
        else
            if ismarked_(c)
                'X'
            else 
                '\u2593' # ▒
            end 
        end  
    end 
       
end

end 
