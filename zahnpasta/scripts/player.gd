class_name Player
extends Area2D

signal health_updated(health: int, max_health: int)
signal moved

const STEP_SIZE = 100
const MAX_STEPS = 4
const MIN_STEPS = 0
const MAX_HEALTH = 5

@export var grid: Grid
@export var score_manager: ScoreManager
@export var movement_tracker: MovementTracker

@onready var audio_player = $AudioStreamPlayer2D

var note_audios = [
	preload("res://assets/sounds/notes/Flute_C4.wav"),
	preload("res://assets/sounds/notes/Flute_D4.wav"),
	preload("res://assets/sounds/notes/Flute_Eb4.wav"),
	preload("res://assets/sounds/notes/Flute_F4.wav"),
	preload("res://assets/sounds/notes/Flute_G4.wav")
]

var current_pitch: int = 2
var current_health: int = MAX_HEALTH


func _ready() -> void:
	_move_on_grid()


func move(value: int, dash: bool):
	print("I like to move it move it!")
	var new_pitch = clampi(current_pitch - (value * (2 if dash else 1)), MIN_STEPS, MAX_STEPS)
	if new_pitch == current_pitch:
		return
	print("Pitch: ", new_pitch)
	current_pitch = new_pitch
	_move_on_grid()
	moved.emit()
	play_note(current_pitch)


func _move_on_grid() -> void:
	grid.move_to_grid(Vector2(0, current_pitch), self)


func play_note(pitch: int) -> void:
	print(pitch)
	audio_player.stream = note_audios[current_pitch]
	audio_player.play()


func take_damage() -> void:
	current_health -= 1
	health_updated.emit(current_health, MAX_HEALTH)
	score_manager.update_combo(0)


func get_pitch() -> int:
	return current_pitch


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullets"):
		take_damage()
		area.queue_free()
