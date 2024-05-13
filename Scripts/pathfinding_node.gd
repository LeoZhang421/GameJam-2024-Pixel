extends Node
class_name Pathfinding_Node

var parent
var g
var h : float
var f : float

# Called when the node enters the scene tree for the first time.
func _init():
	parent = Vector2.ZERO

	g = 0
	h = 0
	f = 0
