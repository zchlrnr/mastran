Feature Conceptualization
=========================
It is the goal of this document to act as a conceptual mockup space and
brainstorming stack for features I want to add, and the methods I would go about
to add them.

E2N Feature Completion in E2N_E2P_E2T.m
---------------------------------------
DESCRIPTION: Finish implenting refactored E2N legacy function 
* Complete simple field matching for all elements in Types.names

RBAR Tool
---------
DESCRIPTION: RBAR tool for NASTRAN type ambiguous contact modeling.
* Should be able to have many modes of usage. Just to list visualized desired
  use cases
    - Passing in two different lists of Node IDs and for all of list one it
      connects to all of list two. 
    - Passing in two different lists of Node IDs and for all of list one, find
      the nearest node in list two and connect to it.
    - Passing in two different lists of node IDs and for all of list one, find
      the nearest node in list two and connect to it, if and only if it is a
      node that can be attached to without throwing nastran errors (can't find
      any examples of this but I've seen it, where the central node of an RBAR
      can't be a node of an RBE2 or something)
* Saves out rbars as a new individual bdf for later either conversion or 

Element2Material Array
----------------------
DESCRIPTION: Acts as a map between Element ID and Material ID. Akin to E2N.
* Ought not need to store or interpret material data itself
* The details of trying to document the intricacies of material property mapping
  are beyond the scope of this subroutine.

Freebody Set Specification Toolset (based on MONPNT3)
-----------------------------------------------------
DESCRIPTION: Enable automated margin computation on predefined cross sections 
* Intended to remove human error from consideration in post processing a coarse
  loads FEM.

Rolling Node Assasin
--------------------
DESCRIPTION: Find nodes rolling away in an f06 file and make a fixing SPC bdf
* Search through the F06, find any and all nodes running away in 4, 5, and 6
* If any nodes have only one or two of the three, must check that as well and
  notify user.

Mesh Equivolence 
-----------------
DESCRIPTION: Allow the equivolencing of nodes in individual bdfs
* Take in nodelist and search tolerance
* Create list of nodes that can be equivolenced
* Prefer keeping either the higher node ID, lower node ID, or placing at
  midpoint
* Check if each equivolence would collapse an element
* If not, do it, save it out to a new bdf.

Transformation Tool
-------------------
DESCRIPTION: Enable movement of bdfs
* Support transformations and rotations.
* What preliminary features do I want to add?
    - Transformation tools (translate and rotate)
