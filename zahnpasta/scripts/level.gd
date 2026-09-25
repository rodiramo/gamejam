class_name HUD
extends Node2D

enum State{
	RUNNING,
	PAUSED
}

@export var config: LevelConfig

@onready var rythm_manager: RythmManager = $RythmManager

var _state: State = State.PAUSED


func _ready() -> void:
	self.rythm_manager.initialize(config)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("resume") and _state == State.PAUSED:
		self.rythm_manager.start()
		_state = State.RUNNING
	elif Input.is_action_just_pressed("pause") and _state == State.RUNNING:
		self.rythm_manager.stop()
		_state = State.PAUSED
