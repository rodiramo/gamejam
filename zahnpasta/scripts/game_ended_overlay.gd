class_name GameEndedOverlay
extends CanvasLayer

signal retry_pressed
signal replay_pressed
signal back_to_main_menu_pressed


@onready var title_label = $Panel/TitleLabel
@onready var score_label = $Panel/ScoreLabel


func set_game_won_state(score: int) -> void:
	title_label.text = "You won!"
	score_label.text = "Score: %d" % score


func set_game_over_state(score: int) -> void:
	title_label.text = "Game over"
	score_label.text = "Score: %d" % score


func _on_retry_button_pressed() -> void:
	retry_pressed.emit()


func _on_back_to_main_menu_button_pressed() -> void:
	back_to_main_menu_pressed.emit()


func _on_replay_button_pressed() -> void:
	replay_pressed.emit()
