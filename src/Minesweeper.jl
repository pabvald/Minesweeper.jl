module Minesweeper

# 3rd Party Dependencies
# ---------------------
using Revise

# Local Dependencies
# ---------------------
include("Boards.jl")
using .Boards

# Module Constants
# ---------------------
const MAIN_MENU = """

MINESWEEPER
-----------
1. Beginner (9x9, 10 mines)
2. Intermediate (16x16, 40 mines)
3. Expert (16x30, 99 mines)
4. Read from file 
5. Exit 

Choose an option:"""
const FILE_MENU = "\nPlease, introduce the filename: "
const PLAY_MENU = "\nIndicate cell and action (! mark, * open): "
const WIN_MESSAGE = "\n Congrats, you have WON the game!!!"
const LOSS_MESSAGE = "\nYou have lost, L ..."
const MAX_ROWS = 30
const MAX_COLS = 30
const ERROR_MSGS = Dict(
    # key : error message
    "wrong_input" => "WRONG INPUT",
    
)


# Auxiliary Functions
# ---------------------

"""
    validfileformat(content::Vector{String})
"""
function validfileformat(content::Vector{String})::Bool
    # read n_rows and n_cols
    s = split(strip(content[1]))
    n_rows = parse(Int, s[1])
    n_cols = parse(Int, s[2])

    if length(content[2:end]) != n_rows
        return false
    end

    for row in content[2:end]
        if length(strip(row)) != n_cols
            return false
        end
        for col in strip(row)
            if !(col in ".*")
                return false
            end
        end
    end

    return true
end

# Primary Functions
# ---------------------

"""
    loadboard()

Loads the specification of a Board from a text file.
"""
function loadboard()::Vector{String}
    filename = ""
    filepath = ""
    read = false
    content::Union{Vector{String},Nothing} = nothing

    while !read
        try
            # ask user for filename
            print(FILE_MENU)
            filename = readline()
            filepath = "src/data/$(filename)"

            # check if file exists
            !isfile(filepath) && throw(ErrorException("`$(filepath)` is not a file"))

            # read file
            content = readlines(filepath)
            # check format
            !validfileformat(content) && throw(ErrorException("invalid file format"))

            read = true
        catch e
            print("Error - $(e.msg)")
        end
    end # while 

    content
end

"""
    play(board::Board)

Controls the flow the game asking the user for a play and applying on the board
"""
function play(board::Board)

    while !isfinished(board)
        print(board)
        print(PLAY_MENU)
        allinputs = readline()

        i = 1
        error = false      

        while i < length(allinputs) && !error

            input = allinputs[i:min(i + 2, length(allinputs))]

            try
                if length(input) != 3 || 
                    !(input[1] in rownames(board)) || 
                    !(input[2] in colnames(board)) || 
                    !(input[3] in actionsymbols(board))
                        throw(ErrorException(ERROR_MSGS["wrong_input"]))
                end

                # create play 
                row, col, action = input
                p = Play(row, col, action)
                           
                # play 
                play!(board, p)

                i += 3
            catch e
                print(e.msg)
                error = true
            end
        end # while 2
    end # while 1

    if iswon(board)
        print(LOSS_MESSAGE)
    else 
        print(WIN_MESSAGE)
    end 
end


"""
    main()

Initiates the Minesweeper game.
"""
function main()
    exit = false

    while !exit
        print(MAIN_MENU)
        selec = parse(Int16, readline())

        # Random - beginner level 
        if selec == 1
            board = Board(:beginner)
            play(board)
            # random - intermediate level 
        elseif selec == 2
            board = Board(:intermediate)
            play(board)
            # random - expert level 
        elseif selec == 3
            board = Board(:expert)
            play(board)
            # load level
        elseif selec == 4
            description = loadboard()
            board = Board(description)
            play(board)
            # exit
        elseif selec == 5
            print("Good bye!!\n")
            exit = true
        else
            print("Invalid input - please, choose an option 1, 2, 3, 4 or 5\n")
        end
    end # while
end

end # module