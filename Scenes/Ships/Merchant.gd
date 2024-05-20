class_name Merchant extends Area2D

# control variables
@export_range(0,500,1) var move_speed: int = 100 # 每帧移动多少像素
@export_range(1,20,1) var max_hp: int = 15

@export var route:Array

# inner variables
var hp: int = 0
var movement: float = 0.0
var current_index: int
var moving: bool = false
var direction

# ready functions
@onready var timer_b = $TimerB
@onready var label = $Label
@onready var label_animation = $Label/AnimationPlayer
@onready var animation = $AnimationPlayer

# signals
signal died
signal arrived_dest
signal arrived_habour

# basic functions
func _ready():
	hp = max_hp
	$HealthBar.max_value = max_hp
	_update_health()
	animation.play("default")
	label.hide()
	move_speed *= Level.tile_size.x / 15
	#start_sail([Vector2(510, 570), Vector2(510, 630), Vector2(510, 690), Vector2(570, 690), Vector2(630, 690), Vector2(690, 690)])

func _process(delta):
	if moving:
		if current_index + direction < 0:
			_arrive_habour()
		elif current_index + direction >= route.size():
			_arrive_dest()
		else:
			movement += delta * move_speed
			var distance = route[current_index].distance_to(route[current_index+direction])
			if route[current_index].x <= route[current_index+direction].x:
				$TextureRect.flip_h = true
			else:
				$TextureRect.flip_h = false
			if movement < distance:
				position = route[current_index] * (1-movement/distance) + route[current_index+direction] * (movement/distance)
			else:
				movement = 0
				current_index = current_index + direction
				position = route[current_index]


# inner functions
func _update_health() -> void:
	$HealthBar.value = hp

func _arrive_habour():
	moving = false
	Character.add_gold(15)
	label.show()
	label_animation.play("pop")
	animation.play("pop")
	await label_animation.animation_finished
	hide()
	timer_b.start()

func _arrive_dest():
	moving = false
	Character.save_gold(15)
	label.show()
	label_animation.play("pop")
	animation.play("pop")
	await label_animation.animation_finished
	hide()
	queue_free()

# behaviour functions
func take_damage(source, damage:int):
	hp -= damage
	_update_health()
	if hp <= 0:
		died.emit(self)
		moving = false
		var smoke_effect = load("res://Scenes/VFX/Smoke_Effect.tscn").instantiate()
		add_child(smoke_effect)
		$ExplodeSound.play()
		moving = false
		animation.play("pop")
		await smoke_effect.finished
		get_parent().remove_child(self)
		queue_free()

func start_sail(value:Array):
	route = value
	direction = -1
	moving = true
	current_index = route.size()-1
	show()

func start_sail_dest():
	direction = +1
	moving = true
	current_index = 0
	animation.play("default")
	hp = max_hp
	_update_health()
	show()

# singal functions
func _on_timer_b_timeout():
	start_sail_dest()
