class_name Merchant extends Area2D

# control variables
@export_range(0,500,1) var move_speed: int = 50 # 每帧移动多少像素
@export_range(1,20,1) var max_hp: int = 15

@export var route:Array

# inner variables
var hp: int = 0
var movement: float = 0.0
var distance: float = 0.0


# signals
signal died
signal arrived_dest
signal arrived_habour

# basic functions
func _ready():
	hp = max_hp
	print(route)
	$HealthBar.max_value = max_hp
	_update_health()
	$AnimationPlayer.play()

func _process(delta):
	movement += delta * move_speed
	#position = start_location * (movement/distance) + end_location * (1-movement/distance)


# inner functions
func _update_health() -> void:
	$HealthBar.value = hp


# behaviour functions
func take_damage(source, damage:int):
	hp -= damage
	_update_health()
	if hp <= 0:
		died.emit(self)
		get_parent().remove_child(self)
		queue_free()
