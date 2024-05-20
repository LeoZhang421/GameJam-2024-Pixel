extends Node2D
@onready var monster_list:Array[PackedScene]
@onready var monster_count:Array[int]
@onready var monster_waittime:Array[float]
@export var small_tick:float
@export var monster_list_1:Array[PackedScene]
@export var monster_count_1:Array[int]
@export var monster_waittime_1:Array[float]
@export var monster_list_2:Array[PackedScene]
@export var monster_count_2:Array[int]
@export var monster_waittime_2:Array[float]
@export var monster_list_3:Array[PackedScene]
@export var monster_count_3:Array[int]
@export var monster_waittime_3:Array[float]

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	$Small_Tick.wait_time = small_tick
	load_generator()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func load_generator():
	match Level.get_current_turn():
		1:
			monster_list = monster_list_1.duplicate(true)
			monster_count = monster_count_1.duplicate(true)
			monster_waittime = monster_waittime_1.duplicate(true)
		2:
			monster_list = monster_list_2.duplicate(true)
			monster_count = monster_count_2.duplicate(true)
			monster_waittime = monster_waittime_2.duplicate(true)
		3:
			monster_list = monster_list_3.duplicate(true)
			monster_count = monster_count_3.duplicate(true)
			monster_waittime = monster_waittime_3.duplicate(true)

func start_generating():
	load_generator()
	$Small_Tick.start()

func generate_next_wave():
	monster_list.pop_front()
	monster_count.pop_front()
	monster_waittime.pop_front()
	if monster_list.size() > 0:
		$Big_Tick.wait_time = monster_waittime[0]
		$Big_Tick.start()
		get_tree().get_root().get_node("Main").set_process(false)
	else:
		get_tree().get_root().get_node("Main").set_process(true)


func _on_big_tick_timeout():
	$Small_Tick.start()


func _on_small_tick_timeout():
	if monster_list.size() <= 0:
		get_tree().get_root().get_node("Main").set_process(true)
		return
	if monster_count[0] <= 0:
		generate_next_wave()
	else:
		var monster = monster_list[0].instantiate()
		monster.start_location = self.global_position
		print(global_position)
		get_tree().get_root().get_node("Main/EnemyLayer").add_child(monster)
		monster_count[0] -= 1
		$Small_Tick.start()
