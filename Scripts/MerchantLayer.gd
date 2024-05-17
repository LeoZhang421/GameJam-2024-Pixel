extends Node

var sail_routes: Array = []
@export var merchant_scene : PackedScene

func generate_merchants():
	for route in sail_routes:
		var merchant:Merchant = merchant_scene.instantiate()
		merchant.route = route
		add_child(merchant)
