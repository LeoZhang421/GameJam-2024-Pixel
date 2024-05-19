extends Node2D
@onready var lifetime_timer = $LifeTime

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	lifetime_timer.wait_time = max($Dust.lifetime, $Debris.lifetime)
	$Dust.one_shot = true
	$Debris.one_shot = true
	$Spark.play("Spark")
	lifetime_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_life_time_timeout():
	finished.emit()
	queue_free()

