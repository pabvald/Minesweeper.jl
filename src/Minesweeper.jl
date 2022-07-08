module Minesweeper

# Inclusions
# ---------------------
include("Boards.jl")

# Module Constants
# ---------------------
MAIN_MENU = """

MINESWEEPER
-----------
1. Beginner (9x9, 10 mines)
2. Intermediate (16x16, 40 mines)
3. Expert (16x30, 99 mines)
4. Read from file 
5. Exit 

Choose an option:"""

PLAY_MENU = "\nIndicate cell and action (! mark, * open): "

# Exported references
# ---------------------
export play

# Auxiliary Functions
# ---------------------


# Primary Functions
# ---------------------

"""
    load_board()

Loads the specification of a Board from a text file.
"""
function load_board()
    filename = "" 
    filepath = ""
    read = false 
    content::Union{Vector{String}, Nothing} = nothing

    while !read
        n_rows = -1
        n_cols = -1
        valid = true

        # ask user for filename
        print("\nPlease, introduce the filename: ")
        filename = readline()
        filepath = "src/data/$(filename)"
        
        # check if file exists
        if  !isfile(filepath)
            print("\nError - `$(filepath)` is not a file")
            continue
        end 

        content= readlines(filepath)

        # read n_rows and n_cols
        s = split(strip(content[1]))
        try
            n_rows = parse(Int, s[1])
            n_cols = parse(Int, s[2])
        catch e  
            valid = false
        end
        
        for row in content[2:end]
            if length(strip(row)) != n_cols
                valid = false
                break
            end
            for col in strip(row)
                if !(col in ".*")
                    valid = false 
                    break
                end
            end
        end

        if !valid
            print("\nError - invalid file format")
            continue
        end 

        read = true
        
    end # while 

    content
end 


function play(b::Boards.Board)

    while !Boards.isfinished(b)
        print(b)
        print(PLAY_MENU)

        i = 1
        allinput = readline()

        while i < length(allinput) 
            input = allinput[i:min(i+2, length(allinput))]
            print(input * "\n")
            i +=3
        end       
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

        if selec == 1
            board = Boards.Board(:beginner)
            play(board)
        elseif selec == 2
            board = Boards.Board(:intermediate)
            play(board)
        elseif selec == 3
            board = Boards.Board(:expert)
            play(board)
        elseif selec == 4
            description = load_board()
            board = Boards.Board(description)
            play(board)
        elseif selec == 5
            print("Good bye!!\n")
            exit = true
        else
            print("Invalid input - please, choose an option 1, 2, 3, 4 or 5\n")
        end

    end
end

end # module
