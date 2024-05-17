extends AudioStreamPlayer
@onready var db_tween : Tween = Tween.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(volume_db)
	
func fade_out():
	db_tween.tween_property(self, "volume_db", -80.0, 5.0)