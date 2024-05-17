class_name Enemy extends Area2D

# control variables
@export_range(0,500,1) var move_speed: int = 50 # 每帧移动多少像素
@export_range(1,20,1) var max_hp: int = 10
@export_range(1,20,1) var attack: int = 2
@export_range(0.0, 10.0) var attack_speed: float = 0.5 # 每秒攻击多少次，越高攻速越快
@export_range(0, 600, 60) var attack_range: int = 4 * 60 # 60像素的倍数
@export var start_location: Vector2 = Vector2(500,500)
@export var end_location: Vector2 = Vector2(1000,500)

# inner variables
var hp: int = 0
var movement: float = 0.0
var direction: bool = true # true表示从起点到终点，false表示从终点到起点
var distance: float = 0.0
var target: Area2D = null
var target_backup: Array[Area2D] = []
var attacking: bool = false

# onready node variables
@onready var area_attack_shape = %AreaAttackShape


# signals
signal died

# basic functions
func _ready():
	hp = max_hp
	distance = start_location.distance_to(end_location)
	$AnimatedSprite2D.play()
	$HealthBar.max_value = max_hp
	_update_health()
	
	target = null
	attacking = false
	$AttackTimer.wait_time = 1.0 / attack_speed
	$AttackTimer.start()
	area_attack_shape.shape.radius = attack_range

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
	target.take_damage(self, attack)


# funcion related to signal
func _on_area_attack_area_entered(enemy:Node):
	print("entered: ", enemy.get_groups())
	if not enemy.is_in_group("Ship"):
		print("not in, passed")
		return
	if not enemy in target_backup:
		target_backup.append(enemy)
		if not enemy.died.is_connected(_on_enemy_died):
			enemy.died.connect(_on_enemy_died)
	set_target()

func _on_area_attack_area_exited(enemy):
	if not enemy.is_in_group("Ship"):
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
