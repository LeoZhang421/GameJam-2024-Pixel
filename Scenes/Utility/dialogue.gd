extends CanvasLayer

signal is_end()

@export var dialogue_path = "res://Dialogue/tutorial.json"
@export var textspeed = 0.05
@export var portrait_path = ""

var dialogue
var phrase_number = 0
var is_finished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = textspeed
	dialogue = get_dialogue()
	assert(dialogue, "dialogue not found")
	next_phrase()
	$Control/ColorRect/Text.push_font(load("res://Assets/Fonts/joystix/joystix monospace.otf"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if is_finished:
			next_phrase()
		else:
			$Control/ColorRect/Text.visible_characters = len($Control/ColorRect/Text.text)
	
func get_dialogue():
	var f = FileAccess.open(dialogue_path, FileAccess.READ)
	var json = f.get_as_text()
	var output = JSON.parse_string(json)
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []
		
func next_phrase():
	if phrase_number >= len(dialogue):
		emit_signal("is_end")
		Character.is_new = false
		queue_free()
		return
	is_finished = false
	$Control/ColorRect/Name.text = dialogue[phrase_number]["Name"]
	$Control/ColorRect/Text.text = dialogue[phrase_number]["Text"]
	$Control/ColorRect/Text.visible_characters = 0
	
	while $Control/ColorRect/Text.visible_characters < len($Control/ColorRect/Text.text):
		$Control/ColorRect/Text.visible_characters += 1
		$Timer.start()
		await $Timer.timeout
	is_finished = true
	phrase_number += 1
	return
