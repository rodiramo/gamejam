class_name GameEndedOverlay
extends CanvasLayer

signal retry_pressed
signal replay_pressed
signal back_to_main_menu_pressed


@onready var title_label = $Panel/TitleLabel
@onready var score_label = $Panel/ScoreLabel
@onready var video_player = $VideoPlayer


var game_over_video = preload("res://assets/videos/game_over_stage.ogv")
var game_won_video = preload("res://assets/videos/win_stage.ogv")


func set_game_won_state(score: int) -> void:
	title_label.text = "You won!"
	score_label.text = "Score: %d" % score
	self.show()
	video_player.show()
	video_player.stream = game_won_video
	video_player.play()
	await video_player.finished
	video_player.hide()


func set_game_over_state(score: int) -> void:
	title_label.text = "Game over"
	score_label.text = "Score: %d" % score
	self.show()
	video_player.show()
	video_player.stream = game_over_video
	video_player.play()
	await video_player.finished
	video_player.hide()


func _on_retry_button_pressed() -> void:
	retry_pressed.emit()


func _on_back_to_main_menu_button_pressed() -> void:
	back_to_main_menu_pressed.emit()


func _on_replay_button_pressed() -> void:
	replay_pressed.emit()
