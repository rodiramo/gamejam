extends Node2D

signal switch_audio(a: int, b: int)

enum State{
	RUNNING,
	PAUSED,
	GAME_OVER
}

@export var config: LevelConfig

@onready var rythm_manager: RythmManager = $RythmManager
@onready var bullet_manager: BulletManager = $BulletManager
@onready var score_manager: ScoreManager = $ScoreManager

var _state: State = State.PAUSED
var combo: int = 0

func _ready() -> void:
	self.rythm_manager.initialize(config)
	self.bullet_manager.initialize(config)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("resume") and _state == State.PAUSED:
		self.rythm_manager.start()
		_state = State.RUNNING
	elif Input.is_action_just_pressed("pause") and _state == State.RUNNING:
		self.rythm_manager.stop()
		_state = State.PAUSED


var max_intensity := 5
var intensity := 0

func _switch_audio() -> void:
	switch_audio.emit(intensity, max_intensity)


func _on_player_health_updated(health: int, _max_health: int) -> void:
	if health <= 0:
		self.rythm_manager.stop()
		_state = State.GAME_OVER


func _on_player_moved() -> void:
	if self.rythm_manager.is_on_beat():
		combo += 1
	else:
		combo = 0
	
	self.score_manager.update_combo(combo)
