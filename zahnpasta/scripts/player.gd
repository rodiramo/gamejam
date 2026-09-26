extends StaticBody2D

const STEP_SIZE = 100
const MAX_STEPS = 5
const MIN_STEPS = 0

@onready var audio_player = $AudioStreamPlayer2D

var note_audios = [
	preload("res://assets/sounds/notes/Flute_C4.wav"),
	preload("res://assets/sounds/notes/Flute_D4.wav"),
	preload("res://assets/sounds/notes/Flute_Eb4.wav"),
	preload("res://assets/sounds/notes/Flute_F4.wav"),
	preload("res://assets/sounds/notes/Flute_G4.wav")
	]

var current_pitch: int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("up"):
		step(1)

	if Input.is_action_just_pressed("down"):
		step(-1)

func step(value: int):
	var double_step = 2 if Input.is_action_pressed("double_step") else 1
	
	var new_pos = current_pitch + (value * double_step)
	if new_pos >= MAX_STEPS or new_pos < MIN_STEPS:
		double_step = 1
		new_pos = current_pitch + value
		if new_pos >= MAX_STEPS or new_pos < MIN_STEPS:
			return
	
	position.y -= STEP_SIZE * value * double_step
	current_pitch += value * double_step
	play_note(current_pitch)
		

func play_note(pitch: int) -> void:
	print(pitch)
	audio_player.stream = note_audios[current_pitch]
	audio_player.play()
