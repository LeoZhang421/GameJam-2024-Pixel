extends Node

var sail_routes: Array = []
var merchant_per_route: Array[int] = []
@export var merchant_scene : PackedScene

@onready var timer_a = $TimerA

# behaviour functions
func reset(value:Array):
	sail_routes = value
	merchant_per_route = []
	for route in sail_routes:
		merchant_per_route.append(0)

func start_action():
	timer_a.start()

func generate_merchants():
	for i in range(sail_routes.size()):
		if merchant_per_route[i] < 5:
			var merchant:Merchant = merchant_scene.instantiate()
			add_child(merchant)
			merchant.start_sail(sail_routes[i])
			merchant_per_route[i] += 1

# singal functions
func _on_timer_a_timeout():
	generate_merchants()
