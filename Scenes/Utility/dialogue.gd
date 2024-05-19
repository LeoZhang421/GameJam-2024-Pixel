extends CanvasLayer

signal is_end()

@export var dialogue_path = ""
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if is_finished:
			next_phrase()
		else:
			$ColorRect/Text.visible_characters = len($ColorRect/Text.text)
	
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
		queue_free()
		return
	is_finished = false
	$ColorRect/Name.text = dialogue[phrase_number]["Name"]
	$ColorRect/Text.text = dialogue[phrase_number]["Text"]
	$ColorRect/Text.visible_characters = 0
	
	var portrait = load(str(portrait_path + dialogue[phrase_number]["Name"] + "_portrait.png"))
	if dialogue[phrase_number]["Name"] == "Me":
		$GridContainer/Player.modulate = Color(1,1,1,1)
		$GridContainer/Player.texture = portrait
		$GridContainer/NPC.modulate = Color(0.4,0.4,0.4,0.6)
	else:
		$GridContainer/NPC.modulate = Color(1,1,1,1)
		$GridContainer/NPC.texture = portrait
		$GridContainer/Player.modulate = Color(0.4,0.4,0.4,0.6)
	
	while $ColorRect/Text.visible_characters < len($ColorRect/Text.text):
		$ColorRect/Text.visible_characters += 1
		$Timer.start()
		await $Timer.timeout
	is_finished = true
	phrase_number += 1
	return
