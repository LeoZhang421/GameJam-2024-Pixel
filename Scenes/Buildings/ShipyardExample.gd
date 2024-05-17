class_name Port extends Area2D

# control variables
@export_range(1,20,1) var max_hp: int = 5
@export_range(1,20,1) var attack: int = 1
@export var start_location: Vector2 = Vector2(500,500)

# inner variables
var hp: int = 0
var target: Area2D = null
#var resting: bool = true

# signals


# basic functions
func _ready():
	position = start_location
	hp = max_hp
	#resting = true
	$AnimatedSprite2D.play()

func _process(delta):
	pass

