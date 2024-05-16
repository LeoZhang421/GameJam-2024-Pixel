extends Camera2D
var dead_zone = 500

# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventMouseMotion:
		var target = event.position - get_viewport().size * 0.5
		if target.length() < dead_zone:
			self.position = Vector2.ZERO
		else:
			self.position = target.normalized() * (target.length() - dead_zone) * 1.5



