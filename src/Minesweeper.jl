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

Choose an option:
"""

# Exported references
# ---------------------
export play

# Auxiliary Functions
# ---------------------


# Primary Functions
# ---------------------

function read_file()
    filename = "" 
    filepath = ""
    content = ""
    read = false 

    while !read
        # ask user for filename
        print("\nPlease, introduce the filename: ")
        filename = readline()
        filepath = joinpath("src", "data", filename)

        # check if file exists
        f = open(filepath, "r") 
        print(typeof(f))
        if isfile(f)
            content = read(f, String)
            read = true
        else    
            print("\nError - `$(filepath)` is not a file")
        end 
        close(f)

    end # while 

    content
end 


"""

"""
function play()
    exit = false 

    while !exit 

        print(MAIN_MENU)
        selec = parse(Int16, readline())

        if selec == 1
            board = Boards.Board(:beginner)
        elseif selec == 2
            board = Boards.Board(:intermediate)
        elseif selec == 3
            board = Boards.Board(:expert)
        elseif selec == 4
            filecontent = read_file()
            board = Boards.Board(filecontent)
        elseif selec == 5
            print("Good bye!!\n")
            exit = true
        else
            print("Invalid input - please, choose an option 1, 2, 3, 4 or 5\n")
        end

    end
end

end # module
