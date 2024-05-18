extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Start_Button.position += get_viewport_rect().size/2
	$Start_Button.position.y += 60
	$Title.position += get_viewport_rect().size/2
	$Title.position.y -= 240
	$AudioStreamPlayer.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
	Level.complete_level()


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()
