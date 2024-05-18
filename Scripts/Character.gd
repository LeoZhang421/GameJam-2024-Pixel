extends Node
@onready var gold:int = 0
@onready var future_gold:int = 0
@onready var max_hp:int = 100
@onready var current_hp:int = max_hp
@onready var max_buildable_ships:int
@onready var current_built_ships:int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# behaviour functions
func reset():
	gold = 0
	future_gold = 0
	current_hp = max_hp
	max_buildable_ships = 0

func add_gold(value:int):
	gold += value

func loss_gold(value:int):
	gold = max(0, gold-value)

func save_gold(value:int):
	future_gold += value

func add_hp(value:int):
	current_hp = min(max_hp, current_hp+value)

func loss_hp(value:int):
	current_hp = max(0, current_hp-value)
