extends Node
@onready var gold:int = 200
@onready var future_gold:int = 0
@onready var max_hp:int = 100
@onready var current_hp:int = max_hp
@onready var max_buildable_ships:int
@onready var current_built_ships:int
signal character_die

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# behaviour functions
func reset():
	match Level.get_current_level():
		1:
			gold = 200
		2:
			gold = 100
		3:
			gold = 100
	future_gold = 0
	current_hp = max_hp
	max_buildable_ships = 0

func add_gold(value:int):
	gold += value

func loss_gold(value:int):
	var temp = gold
	gold = max(0, gold-value)
	return gold >= value

func save_gold(value:int):
	future_gold += value

func add_hp(value:int):
	current_hp = min(max_hp, current_hp+value)

func loss_hp(value:int):
	current_hp = max(0, current_hp-value)
	if current_hp == 0:
		emit_signal("character_die")
