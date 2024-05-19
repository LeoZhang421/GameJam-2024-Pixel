extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var canvas = get_canvas_transform()
	var top_left = - canvas.origin / canvas.get_scale()
	var size = get_viewport_rect().size / canvas.get_scale()
	set_sprite_position(Rect2(top_left, size))
	
	
	
func set_sprite_position(borders:Rect2):
	$Sprite2D.global_position.x = clamp(global_position.x, borders.position.x, borders.end.x)
	$Sprite2D.global_position.y = clamp(global_position.y, borders.position.y, borders.end.y)
