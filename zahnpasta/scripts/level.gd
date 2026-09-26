extends Node2D

signal switch_audio(a: int, b: int)

enum State{
	COUNT_IN,
	RUNNING,
	PAUSED,
	GAME_OVER,
	GAME_WON
}

@export var config: LevelConfig
@export var count_in_seconds: int = 3

@onready var rythm_manager: RythmManager = $RythmManager
@onready var bullet_manager: BulletManager = $BulletManager
@onready var score_manager: ScoreManager = $ScoreManager
@onready var count_in_timer: Timer = $CountInTimer
@onready var count_in_overlay: Node = $CountInOverlay
@onready var pause_overlay: PauseOverlay = $PauseOverlay
@onready var game_ended_overlay: GameEndedOverlay = $GameEndedOverlay

var _state: State = State.COUNT_IN
var combo: int = 0
var max_intensity := 5
var intensity := 0
var _count_in_seconds_remaining := count_in_seconds


func _ready() -> void:
	self.rythm_manager.initialize(config)
	self.bullet_manager.initialize(config)
	
	if _count_in_seconds_remaining > 0:
		count_in_overlay.show()
		count_in_overlay.show_count(_count_in_seconds_remaining)
	else:
		resume_game()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and _state == State.RUNNING:
		pause_game()


func resume_game() -> void:
	self.rythm_manager.start()
	_state = State.RUNNING
	get_tree().paused = false
	pause_overlay.hide()


func pause_game() -> void:
	self.rythm_manager.stop()
	_state = State.PAUSED
	get_tree().paused = true
	pause_overlay.show()


func _switch_audio() -> void:
	switch_audio.emit(intensity, max_intensity)


func end_game(state: State) -> void:
	self.rythm_manager.stop()
	_state = state
	get_tree().paused = true
	
	if state == State.GAME_WON:
		game_ended_overlay.set_game_won_state(score_manager.current_score())
	elif state == State.GAME_OVER:
		game_ended_overlay.set_game_over_state(score_manager.current_score())
	else:
		get_tree().exit(1)
	
	game_ended_overlay.show()


func go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_rythm_manager_level_ended() -> void:
	end_game(State.GAME_WON)


func _on_player_health_updated(health: int, _max_health: int) -> void:
	if health <= 0:
		end_game(State.GAME_OVER)


func _on_player_moved() -> void:
	if self.rythm_manager.is_on_beat():
		combo += 1
	else:
		combo = 0
	
	self.score_manager.update_combo(combo)


func _on_count_in_timer_timeout() -> void:
	_count_in_seconds_remaining -= 1
	
	if _count_in_seconds_remaining <= 0:
		count_in_timer.stop()
		count_in_overlay.hide()
		resume_game()
	else:
		count_in_overlay.show_count(_count_in_seconds_remaining)


func _on_game_ended_overlay_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_game_ended_overlay_replay_pressed() -> void:
	pass
