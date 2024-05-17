class_name Turrent extends Area2D

# control variables
@export_range(0, 600, 60) var attack_range: int = 4 * 60 # 60像素的倍数
@export_range(0.0, 10.0) var attack_speed: float = 0.5 # 每秒攻击多少次，越高攻速越快
#@export_range(1,20,1) var max_hp: int = 5
@export_range(1,20,1) var attack: int = 1
@export var start_location: Vector2 = Vector2(500,500)

# inner variables
#var hp: int = 0
var target: Area2D = null
var target_backup: Array[Area2D] = []
var attacking: bool = false
var is_on_land := true


# onready node variables
@onready var area_attack_shape = %AreaAttackShape

# signals


# basic functions
func _ready():
	position = start_location
	#hp = max_hp
	target = null
	attacking = false
	$AnimatedSprite2D.play()
	$AttackTimer.wait_time = 1.0 / attack_speed
	$AttackTimer.start()
	area_attack_shape.shape.radius = attack_range

func _process(delta):
	pass


# behaviour functions
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

func demolish():
	self.queue_free()

# funcion related to signal
# when enemy Area2D entered attack area
func _on_area_attack_area_entered(enemy):
	if not enemy.is_in_group("Enemy"):
		return
	if not enemy in target_backup:
		target_backup.append(enemy)
		if not enemy.died.is_connected(_on_enemy_died):
			enemy.died.connect(_on_enemy_died)
	set_target()

# when enemy Area2D left attack area
func _on_area_attack_area_exited(enemy):
	if not enemy.is_in_group("Enemy"):
		return
	if enemy in target_backup:
		target_backup.erase(enemy)
		if enemy.died.is_connected(_on_enemy_died):
			enemy.died.disconnect(_on_enemy_died)
	set_target()

# when target enemy died
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
