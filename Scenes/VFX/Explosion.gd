extends Node2D
@onready var lifetime_timer = $LifeTime

# Called when the node enters the scene tree for the first time.
func _ready():
	lifetime_timer.wait_time = max($Dust.lifetime, $Debris.lifetime)
	$Dust.one_shot = true
	$Debris.one_shot = true
	$Spark.rotation = (randf() - 0.5) * 2 * PI
	$Spark.play("Spark")
	lifetime_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_life_time_timeout():
	queue_free()


func _on_spark_animation_finished():
	$Spark.queue_free()

