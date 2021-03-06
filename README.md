# mastran
matlab/octave toolset for msc nastran bdf manipulation

## Goal
* Create simple subfunctions for commonly performed tasks involving nastran bdf processing and manipulation.

## Style Guide
* Avoid line by line bdf reading if possible
* Utilize the core parent data structures
    * E2N: Element ID to Node ID Map
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
* [2020.06.19] FeatureConceptualization.md
    * It is the goal of this document to act as a conceptual mockup space and
      brainstorming stack for features I want to add, and the methods I would go
      about to add them.

* [2020.05.30] nodal_octtree.m
    * `nearest_node_list = nodal_octtree(varargin)`
    * Takes in two lists of nodal data and the number of subdivisions the
      pointcloud will be split into in each axis.
    * Basically it's "For every node in list 1, find me its nearest node in list
      2!"
    * Returns a 2 column list of nodes in list 1 along with its corresponding
      nearest node in list 2. If the node in list 1 is too far away from any
      node in list 2, then it won't get a mapping.
    * If run with divisions=2, then performance is identical or slightly worse
      than directly computing distance from every node in list 1, to every node
      in list 2.
    * To give an approximate idea of performance, when run with 9000 nodes in
      list 1, and 35000 nodes in list 1; see below (with a "correct" number of
      connections being around 3000). It can be seen that runtime is N^2 or
      worse at 2 divisons, and that it plateaus as the divisions begin to go
      high enough to create erroneous answers. This is a good thing.

    | Divisions |   Runtime | Connections Made|
    |:----------|:---------:|----------------:|
    |     2     |  too long |  All of them    |
    |     5     |~30 minutes|too many of them |
    |    15     |64 seconds |      4082       |
    |    20     |36 seconds |      3850       |
    |    25     |26 seconds |      3392       |
    |    30     |22 seconds |      3320       |
    |    60     |16 seconds |      3200       |
    |   100     |15 seconds |      2909       |
    |   150     |13 seconds |      1694       |
    |   200     |13 seconds |       968       |
    |   300     |13 seconds |       288       |
    |   500     |13 seconds |       74        |


* [2020.04.11] degenerate_negative.m
    * `fixed_number = degenerate_negative(character_string_in)`
    * takes in a single line character string and turns it from reduced
    format nastran format to a readable format. Despite its name, it actually
    deals with all degenerate number forms, not just negatives.
* [2020.04.11] gridpoint_extractor.m
    * `[remaining_bdf, gridpoints] = gridpoint_extractor(bdf)`
    * Takes in either a bdf filename or a character array of the bdf and extracts the gridpoints variable as [Node ID, x coordinate, y coordinate, z coordinate];
    * Outputs all lines of the bdf that are not gridpoints back into the array "remaining_bdf"
