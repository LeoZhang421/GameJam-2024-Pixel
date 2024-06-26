class_name Enemy extends Area2D

# control variables
@export_range(0,500,1) var move_speed: int = 50 # 每帧移动多少像素
@export_range(1,100,1) var max_hp: int = 30
@export_range(1,40,1) var attack: int = 3
@export_range(0.0, 10.0) var attack_speed: float = 0.5 # 每秒攻击多少次，越高攻速越快
@export_range(0, 600, 1) var attack_range: int = 3 * Level.tile_size.x # 60像素的倍数
@export_range(0.0, 1.0, 0.5) var collide_damage: float = 0.5 #撞击时造成多少倍当前hp的伤害
@export var start_location: Vector2 = Vector2(1000,500)
@export_range(0,10,1) var habour_damage: int = 1 # 进入港口时对玩家伤害
@export var merchant_kill_self: bool = false # 击沉商船时是否击沉自己

# inner variables
var hp: int = 0
var movement: float = 0.0
# var direction: bool = true true表示从起点到终点，false表示从终点到起点
var direction: Vector2 #表示船的行进方向
var distance: float = 0.0
var target: Area2D = null
var target_backup: Array[Area2D] = []
var attacking: bool = false
var moving: bool = true
var move_array: Array
var current_index: int

# onready node variables
@onready var area_attack_shape = %AreaAttackShape
@onready var sink_animation = $AnimatedSprite2D/SinkAnimation
@onready var main = get_node("/root/Main")

# signals
signal died

# basic functions
func _ready():
	#scale = Vector2(Level.tile_size)/($AnimatedSprite2D.sprite_frames.get_frame_texture("default", 0).get_size())
	hp = max_hp
	$AnimatedSprite2D.play()
	$HealthBar.max_value = max_hp
	_update_health()
	position = start_location
	
	target = null
	attacking = false
	$AttackTimer.wait_time = 1.0 / attack_speed
	$AttackTimer.start()
	$RerouteTimer.start()
	area_attack_shape.shape.radius = attack_range
	move_speed *= Level.tile_size.x / 15

func _process(delta):
	#if moving and move_array:
		#if current_index >= move_array.size()-1:
			#moving = false
			#move_array = []
		#else:
			#movement += delta * move_speed
			#var distance = move_array[current_index].distance_to(move_array[current_index+1])
			#if movement < distance:
				#position = move_array[current_index] * (1-movement/distance) + move_array[current_index+1] * (movement/distance)
			#else:
				#movement = 0
				#current_index = current_index + 1
				#position = move_array[current_index]
	if moving and move_array:
		var target_position = move_array[0]
		direction = (target_position - global_position).normalized()
		if direction.x >= 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		position += direction * move_speed * delta
		if target_position.distance_to(global_position) <= main.pathfinder.scale/4:
			move_array.pop_front()
			if move_array == [] and main.pathfinder.get_harbour_position().has(main.pathfinder.get_tile_center(global_position)):
				Character.loss_hp(habour_damage)
				take_damage(self, 99)


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
		moving = false
		$RerouteTimer.paused = true
		await smoke_effect.finished
		get_parent().remove_child(self)
		queue_free()

func set_target() -> void:
	if attacking:
		if target in target_backup:
			return
		else:
			if target_backup:
				target = find_closest(target_backup)
				return
			else:
				target = null
				attacking = false
				return
	else:
		if target_backup:
			target = find_closest(target_backup)
			attacking = true
			return
		else:
			target = null
			attacking = false
			return

func find_closest(target_list) -> Area2D:
	var min_enemy:Area2D = target_list[0]
	var min_dist = min_enemy.position.distance_to(position)
	for enemy in target_list:
		if enemy.position.distance_to(position) <= min_dist:
			min_dist = enemy.position.distance_to(position)
			min_enemy = enemy
	return min_enemy

func attack_event() -> void:
	$AttackSound.play()
	target.take_damage(self, attack)

func kill_merchant(merchant) -> void:
	if hp>0:
		merchant.take_damage(self, 99)
		if merchant_kill_self:
			take_damage(self, 99)

# funcion related to signal
func _on_area_attack_area_entered(enemy:Node):
	if not enemy.is_in_group("Ship"):
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


func _on_reroute_timer_timeout():
	if main.get_node("MerchantLayer").get_child_count() >= 2:
		var merchant_list = main.get_node("MerchantLayer").get_children()
		var close = find_closest(merchant_list.slice(1))
		print("Finding way to merchants: from ", position, " to ", close.position)
		var temp = main.pathfinder.find_path(position, close.position)
		if temp:
			moving = true
			# 目标不同才更新寻路，否则不更新
			if move_array == []:
				move_array = temp
				return
			if temp[-1] != move_array[-1]:
				temp.pop_front()
				move_array = temp
				return
	else:
		var harbour_list = main.pathfinder.get_harbour_position()
		var min_harbour:Vector2 = harbour_list[0]
		var min_dist = min_harbour.distance_to(position)
		for harbour in harbour_list:
			if harbour.distance_to(position) <= min_dist:
				min_dist = harbour.distance_to(position)
				min_harbour = harbour
		print("Finding way to harbour: from ", position, " to ", min_harbour)
		var temp = main.pathfinder.find_path(position, min_harbour)
		if temp:
			moving = true
			# 目标不同才更新寻路，否则不更新
			if move_array == []:
				move_array = temp
				return
			if temp[-1] != move_array[-1]:
				temp.pop_front()
				move_array = temp
				return


func _on_area_entered(enemy):
	if enemy.is_in_group("Ship") and enemy.is_in_group("Merchant"):
		kill_merchant(enemy)
	else:
		return
