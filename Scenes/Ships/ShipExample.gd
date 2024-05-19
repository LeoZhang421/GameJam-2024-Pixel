class_name Ship extends Area2D

# control variables
@export_range(0,500,1) var move_speed: int = 50 # 每帧移动多少像素
@export_range(1,100,1) var max_hp: int = 10
@export_range(1,40,1) var attack: int = 2
@export_range(0.0, 10.0) var attack_speed: float = 0.5 # 每秒攻击多少次，越高攻速越快
@export_range(0, 600, 60) var attack_range: int = 4 * 60 # 60像素的倍数
@export_range(0.0, 0.5, 1.0) var collide_damage: float = 0.5 #撞击时造成多少倍当前hp的伤害
@export var start_location: Vector2 = Vector2(500,500)
@export var cost : int = 10

# inner variables
var hp: int = 0
var movement: float = 0.0
var direction: bool = true # true表示从起点到终点，false表示从终点到起点
var distance: float = 0.0
var target: Area2D = null
var target_backup: Array[Area2D] = []
var attacking: bool = false
var colliding: bool = false
var moving: bool = false
var mouse_await: bool = false
var mouse_inside: bool = false
var move_array: Array
var current_index: int

# onready node variables
@onready var area_attack_shape = %AreaAttackShape
@onready var sink_animation = $AnimatedSprite2D/SinkAnimation

# signals
signal died

# basic functions
func _ready():
	hp = max_hp
	$AnimatedSprite2D.play()
	position = start_location
	$HealthBar.max_value = max_hp
	_update_health()
	
	target = null
	attacking = false
	$AttackTimer.wait_time = 1.0 / attack_speed
	$AttackTimer.start()
	area_attack_shape.shape.radius = attack_range

func _process(delta):
	print(position)
	if not mouse_await and mouse_inside and Input.is_action_just_pressed("click"):
		mouse_await = true
		moving = false
	if mouse_await and not mouse_inside and Input.is_action_just_pressed("click"):
		mouse_await = false
		moving = true
		var move_location = get_global_mouse_position()
		move_array = get_node("/root/Main").pathfinder.find_path(position, move_location)
		movement = 0
		current_index = 0
	if moving and move_array:
		if current_index >= move_array.size()-1:
			moving = false
			move_array = []
		else:
			movement += delta * move_speed
			var distance = move_array[current_index].distance_to(move_array[current_index+1])
			if movement < distance:
				position = move_array[current_index] * (1-movement/distance) + move_array[current_index+1] * (movement/distance)
			else:
				movement = 0
				current_index = current_index + 1
				position = move_array[current_index]


# inner functions
func _update_health() -> void:
	$HealthBar.value = hp


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
		sink_animation.play("sink")
		await smoke_effect.finished
		get_parent().remove_child(self)
		queue_free()

func set_target() -> void:
	if attacking:
		if target in target_backup:
			return
		else:
			if target_backup:
				target = find_closest()
				return
			else:
				target = null
				attacking = false
				return
	else:
		if target_backup:
			target = find_closest()
			attacking = true
			return
		else:
			target = null
			attacking = false
			return

func find_closest() -> Area2D:
	assert(target_backup)
	var min_enemy:Area2D = target_backup[0]
	var min_dist = min_enemy.position.distance_to(position)
	for enemy in target_backup:
		if enemy.position.distance_to(position) <= min_dist:
			min_dist = enemy.position.distance_to(position)
			min_enemy = enemy
	return min_enemy

func attack_event() -> void:
	$AttackSound.play()
	target.take_damage(self, attack)

func collide_event(enemy) -> void:
	var receive_dmg = enemy.hp * enemy.collide_damage
	var giving_dmg = hp * collide_damage
	moving = false
	enemy.moving = false
	if not colliding:
		colliding = true
		var fighting_effect = load("res://Scenes/VFX/Combat_Effect.tscn").instantiate()
		add_child(fighting_effect)
		$CollideSound.play()
		fighting_effect.global_position = (enemy.position + position)/2
		await fighting_effect.finished
		colliding = false
	moving = true
	enemy.moving = true
	
	enemy.take_damage(self, giving_dmg)
	take_damage(enemy, receive_dmg)

# funcion related to signal
func _on_area_attack_area_entered(enemy):
	if not enemy.is_in_group("Enemy"):
		return
	if not enemy in target_backup:
		target_backup.append(enemy)
		if not enemy.died.is_connected(_on_enemy_died):
			enemy.died.connect(_on_enemy_died)
	set_target()

func _on_area_attack_area_exited(enemy):
	if not enemy.is_in_group("Enemy"):
		return
	if enemy in target_backup:
		target_backup.erase(enemy)
		if enemy.died.is_connected(_on_enemy_died):
			enemy.died.disconnect(_on_enemy_died)
	set_target()

func _on_enemy_died(enemy):
	assert(enemy in target_backup)
	target_backup.erase(enemy)
	if enemy.died.is_connected(_on_enemy_died):
		enemy.died.disconnect(_on_enemy_died)
	set_target()

func _on_attack_timer_timeout():
	if attacking:
		attack_event()
	else:
		pass

func _on_area_entered(enemy):
	if not enemy.is_in_group("Enemy"):
		return
	else:
		collide_event(enemy)


func _on_mouse_entered():
	if Level.get_current_phase() == "action":
		mouse_inside = true
	

func _on_mouse_exited():
	mouse_inside = false
