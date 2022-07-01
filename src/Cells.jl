"""
    Cells

Includes the Cell struct and all its related functionality. 
"""
module Cells


# Exported references
# ---------------------
export Cell, open!, mark!


# Main functions
# ---------------------
"""
    Cell 

Cell of the board.
"""
mutable struct Cell
    opened::Bool
    marked::Bool 
    hasmine::Bool
end 

"""
    Cell

Cell of the board with a mine if `hasmine' is `true`, empty otherwise
"""
Cell(hasmine) = Cell(false, false, hasmine)

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


function isopen(c::Cell)
    c.opened
end

function ismarked(c::Cell)
    c.marked
end


function hasmine(c::Cell)
    c.hasmine
end 


end 
