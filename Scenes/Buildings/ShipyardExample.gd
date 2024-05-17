class_name Shipyard extends Area2D

# control variables
@export_range(1,20,1) var max_hp: int = 5
@export var start_location: Vector2 = Vector2(500,500)

# inner variables
var hp: int = 0
var target: Area2D = null
#var resting: bool = true

# signals


# basic functions
func _ready():
	Character.max_buildable_ships += 1
	position = start_location
	hp = max_hp
	#resting = true
	$AnimatedSprite2D.play()

func _process(delta):
	pass

func demolish():
	Character.max_buildable_ships -= 1
	self.queue_free()
