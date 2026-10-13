class_name GameEndedOverlay
extends CanvasLayer

signal retry_pressed
signal replay_pressed
signal back_to_main_menu_pressed


@onready var ui = $Panel
@onready var title_label = $Panel/TitleLabel
@onready var score_label = $Panel/ScoreLabel
@onready var highscore_name_input = $Panel/HighscoreNameInput
@onready var save_highscore_button = $Panel/SaveHighscoreButton
@onready var highscore_added_label = $Panel/HighscoreAddedLabel
@onready var video_player = $VideoPlayer
@onready var audio_player = $AudioPlayer


var game_over_video = preload("res://assets/videos/game_over_stage.ogv")
var game_over_audio = preload("res://assets/musik/Zahnpastatypeboos.wav")
var game_won_video = preload("res://assets/videos/win_stage.ogv")
var game_won_audio = preload("res://assets/musik/Zahnpastatypecheers.wav")


var _score: int = 0
var _is_winning_state: bool = false


func _ready() -> void:
	Highscores.score_added.connect(_on_highscores_score_added)
	highscore_added_label.hide()
	
	if Highscores.has_last_submission_this_session():
		highscore_name_input.text = Highscores.get_last_submission_this_session().player_name
		_enable_save_highscore_button()
	else:
		_disable_save_highscore_button()


func set_game_won_state(score: int) -> void:
	_score = score
	_is_winning_state = true
	_update_labels()
	self.show()
	_play_video()


func set_game_over_state(score: int) -> void:
	_score = score
	_is_winning_state = false
	_update_labels()
	self.show()
	_play_video()


func _update_labels() -> void:
	title_label.text = "You won!" if _is_winning_state else "Game over"
	score_label.text = "Score: %d" % _score


func _play_video() -> void:
	ui.hide()
	video_player.show()
	
	if _is_winning_state:
		video_player.stream = game_won_video
		audio_player.stream = game_won_audio
	else:
		video_player.stream = game_over_video
		audio_player.stream = game_over_audio
	
	video_player.play()
	audio_player.play()
	
	await video_player.finished
	ui.show()


func _on_retry_button_pressed() -> void:
	retry_pressed.emit()


func _on_back_to_main_menu_button_pressed() -> void:
	back_to_main_menu_pressed.emit()


func _on_replay_button_pressed() -> void:
	replay_pressed.emit()


func _on_save_highscore_button_pressed() -> void:
	_submit_highscore()


func _submit_highscore() -> void:
	var player_name: String = highscore_name_input.text.strip_edges()
	
	if player_name.is_empty():
		return
	
	highscore_name_input.editable = false
	_disable_save_highscore_button()
	
	var highscore_entry := HighscoreEntry.new(player_name, _score)
	Highscores.add_score(highscore_entry)


func _on_highscores_score_added(entry: HighscoreEntry) -> void:
	highscore_added_label.text = "You're %d. place!" % entry.rank
	highscore_added_label.show()


func _on_highscore_name_input_text_changed(new_text: String) -> void:
	if new_text.strip_edges().is_empty():
		_disable_save_highscore_button()
	else:
		_enable_save_highscore_button()


func _on_highscore_name_input_text_submitted(_new_text: String) -> void:
	_submit_highscore()


func _disable_save_highscore_button() -> void:
	save_highscore_button.disabled = true
	save_highscore_button.modulate = Color.DIM_GRAY


func _enable_save_highscore_button() -> void:
	save_highscore_button.disabled = false
	save_highscore_button.modulate = Color.WHITE
