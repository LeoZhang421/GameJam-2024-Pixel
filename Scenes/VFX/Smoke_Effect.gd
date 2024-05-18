extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Hit_particle.one_shot = true
	$Smoke_particle.one_shot = true
	$Lifetime_timer.wait_time = max($Hit_particle.lifetime, $Smoke_particle.lifetime)
	$Lifetime_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_lifetime_timer_timeout():
	queue_free()
