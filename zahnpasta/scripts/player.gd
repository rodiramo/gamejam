class_name Player
extends Area2D

signal health_updated(health: int, max_health: int)
signal moved

const STEP_SIZE = 100
const MAX_STEPS = 4
const MIN_STEPS = 0
const MAX_HEALTH = 3

@export var grid: Grid
@export var score_manager: ScoreManager

@onready var audio_players = [
	$AudioPitchLane0,
	$AudioPitchLane1,
	$AudioPitchLane2,
	$AudioPitchLane3,
	$AudioPitchLane4
]

var current_pitch: int = 2
var current_health: int = MAX_HEALTH


func _ready() -> void:
	_move_on_grid()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		step(1)
	elif Input.is_action_just_pressed("down"):
		step(-1)


func step(value: int):
	var double_step = 2 if Input.is_action_pressed("double_step") else 1
	
	var new_pitch = clampi(current_pitch - (value * double_step), MIN_STEPS, MAX_STEPS)
	if new_pitch == current_pitch:
		return
	
	current_pitch = new_pitch
	_move_on_grid()
	moved.emit()
	play_note(current_pitch)


func _move_on_grid() -> void:
	grid.move_to_grid(Vector2(0, current_pitch), self)


func play_note(pitch: int) -> void:
	audio_players[current_pitch].play()


func take_damage() -> void:
	current_health -= 1
	health_updated.emit(current_health, MAX_HEALTH)
	score_manager.update_combo(0)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullets"):
		take_damage()
		area.queue_free()
