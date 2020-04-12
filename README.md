# mastran
matlab/octave toolset for msc nastran bdf manipulation

## Goal
* Create simple subfunctions for commonly performed tasks involving nastran bdf processing and manipulation.

## Style Guide
* Avoid line by line bdf reading if possible
* Utilize the core parent data structures
    * E2N: Element ID To Node ID Map
    * E2P: Element ID to Property ID Map
    * E2T: Element ID to Element Type Map
    * Nodes: [NID, X Coord, Y Coord, Z Coord]
* Globally support all three nastran card styles, Short, Long, and comma delimited
* Implement global interrupting error reporting at all subfunction layers
* High level functions ought strive for pseudo-orthogonal argument parsing. This includes such features as
    * bdf interchangeability; wherein one can pass either a character array of the bdf, or the bdf as a structure, or the filename of the bdf
    * loop escape features; wherein a preference exists for while loops over for loops to support incomplete or segmented file searches over specific ranges or for specific quantities
* Practice non-destructive filtering operations. i.e, if the goal is to subtract all instances of MAT1 cards, pass into a function the bdf, and get out the bdf with the mat1 cards, and the mat1 card data themselves. Never pass data into a function that will not pass back all the neccesary information to reconstruct the original state of the data.

## Features [w/ Addition Date]
* [2020.04.11] degenerate_negative.m
    * `fixed_number = degenerate_negative(character_string_in)`
    * takes in a single line character string and turns it from reduced
    format nastran format to a readable format. Despite its name, it actually
    deals with all degenerate number forms, not just negatives.
* [2020.04.11] gridpoint_extractor.m
    * `[remaining_bdf, gridpoints] = gridpoint_extractor(bdf)`
    * Takes in either a bdf filename or a character array of the bdf and extracts the gridpoints variable as [Node ID, x coordinate, y coordinate, z coordinate];
    * Outputs all lines of the bdf that are not gridpoints back into the array "remaining_bdf"
