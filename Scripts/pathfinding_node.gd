class_name Pathfinding_Node

var parent_x
var parent_y
var g
var h : float
var f : float

# Called when the node enters the scene tree for the first time.
func _init():
	parent_x = 0
	parent_y = 0
	g = 0
	h = 0
	f = 0
