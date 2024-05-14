class_name Enemy extends Area2D

# control variables
#@export_range(0.0, 1000.0) var attack_range: float = 400.0
@export_range(0,500,1) var move_speed: int = 50 # 每帧移动多少像素
@export_range(1,20,1) var max_hp: int = 10
@export_range(1,20,1) var attack: int = 2
@export var start_location: Vector2 = Vector2(500,500)
@export var end_location: Vector2 = Vector2(1000,500)

# inner variables
var hp: int = 0
var movement: float = 0.0
var direction: bool = true # true表示从起点到终点，false表示从终点到起点
var distance: float = 0.0

# signals
signal died

# basic functions
func _ready():
	hp = max_hp
	distance = start_location.distance_to(end_location)
	$AnimatedSprite2D.play()
	$HealthBar.max_value = max_hp
	_update_health()

func _process(delta):
	if direction:
		movement += delta * move_speed
		if movement >= distance:
			direction = false
	else:
		movement -= delta * move_speed
		if movement <= 0:
			direction = true
	position = start_location * (movement/distance) + end_location * (1-movement/distance)


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
