extends Node2D


func _ready() -> void:
	var highscore := Highscores.get_current_highest_score()
	$MainMenu/HighscoreContainer/Highscore.text = "%d\n\nby %s" % [highscore.score, highscore.player_name]
	Highscores.scores_updated.connect(_on_highscores_scores_updated)
	$TutorialOverlay.closed.connect(_on_tutorial_overlay_closed)
	$HighscoresListOverlay.closed.connect(_on_highscores_list_overlay_closed)


func _on_highscores_scores_updated(_scores: Array[HighscoreEntry]) -> void:
	var highscore := Highscores.get_current_highest_score()
	$MainMenu/HighscoreContainer/Highscore.text = "%d\n\nby %s" % [highscore.score, highscore.player_name]


func _on_start_button_pressed() -> void:
	ReplaySettings.ready_to_play()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_tutorial_button_pressed() -> void:
	$TutorialOverlay.show()


func _on_tutorial_overlay_closed() -> void:
	$TutorialOverlay.hide()


func _on_highscores_button_pressed() -> void:
	$HighscoresListOverlay.show()


func _on_highscores_list_overlay_closed() -> void:
	$HighscoresListOverlay.hide()
