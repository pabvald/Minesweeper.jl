"""
    Cells

Includes the Cell struct and all its related functionality. 
"""
module Cells

# Base Dependencies
# ---------------------

# Exported references
# ---------------------
export Cell, open!, mark!, mines_left, tochar 

# Constants 
# ---------------------

# Main functions
# ---------------------

"""
    Cell 

Cell of the board.
"""
mutable struct Cell
    opened::Bool
    marked::Bool 
    mined::Bool

    function Cell(hasmine) 
        new(false, false, hasmine)
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
function isopen(c::Cell)
    c.opened
end

"""
    isopen(c::Cell)
Returns `true` if Cell `c` is 'opened'.
"""
function ismarked(c::Cell)
    c.marked
end

"""
    hasmine(c::Cell)
Returns `true` if Cell `c` is 'mined'.
"""
function hasmine(c::Cell)
    c.hasmine
end 

"""
    tochar(c::Cell, n::Int=0)

Provides a character representation of a Cell `c` depending on 
its state and the `n = # of mined neighbours - # of marked neighbours`.
""" 
function tochar(c::Cell, n::Int=0)

    if isopen(c)
        if n > 0
            Char(n)
        elseif n == 0
            ' '
        else # n < 0
            '?'
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
