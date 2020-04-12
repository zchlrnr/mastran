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
