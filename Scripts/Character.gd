extends Node
@onready var gold:int
@onready var max_hp:int = 100
@onready var current_hp:int
@onready var max_buildable_ships:int
@onready var current_built_ships:int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func reset():
	gold = 0
	current_hp = max_hp
	max_buildable_ships = 0
