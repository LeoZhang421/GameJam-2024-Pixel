extends AudioStreamPlayer
@onready var is_fading = false
@onready var fade_duration:float
@onready var volume_offset

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_fading:
		volume_db += volume_offset * delta
	if volume_db <= -40:
		self.stop()
	
func fade_out():
	is_fading = true
	fade_duration = 5
	volume_offset = (-40 - volume_db) /5
	set_process(true)
