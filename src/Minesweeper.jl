module Minesweeper

# Inclusions
# ---------------------
include("Boards.jl")
include("Cells.jl")

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

Choose an option:
"""

# Exported references
# ---------------------
export play

# Auxiliary Functions
# ---------------------


# Primary Functions
# ---------------------

"""
    load_board()

Loads a Board from a text file.
"""
function load_board()
    filename = "" 
    filepath = ""
    content = ""
    read = false 

    while !read
        # ask user for filename
        print("\nPlease, introduce the filename: ")
        filename = readline()
        filepath = "src/data/$(filename)"
        
        # check if file exists
        if isfile(filepath)
            board = readlines(filepath)

            # read n_rows and n_cols
            s = split(strip(board[1]))
            try
                n_rows = parse(Int, s[1])
                n_cols = parse(Int, s[2])
            catch
                print("\nError - invalid file format")
                continue
            end
            
            # create empty array of cells
            cells = Array{Cells.Cell, 2}(undef, n_rows, n_cols)
            
            if length(board) - 1 != n_rows
                print("\nError - invalid file format")
                continue
            end 
            # TODO: fix the format validation
            for (i, row) in enumerate(board[2:end])
                if length(row) != n_cols
                    print("\nError - invalid file format")
                    continue
                end 

                for (j, c) in enumerate(strip(row))
                    hasmine = c == '*' ? true : false
                    cells[i,j] = Cells.Cell(hasmine)
                end
            end

            read = true
        else    
            print("\nError - `$(filepath)` is not a file")
        end 

    end # while 

    Boards.Board(cells)
end 


function play(b::Boards.Board)


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
            board = load_board()
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
