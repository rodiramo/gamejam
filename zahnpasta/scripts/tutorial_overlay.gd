extends CanvasLayer

signal closed

enum State{
	STORY,
	ENEMIES_AND_GAMEPLAY,
	CONTROLS
}

var state: State = State.STORY


func _on_close_button_pressed() -> void:
	closed.emit()


func _on_next_button_pressed() -> void:
	match state:
		State.STORY:
			show_enemies_part()
		State.ENEMIES_AND_GAMEPLAY:
			show_controls_part()


func _on_back_button_pressed() -> void:
	match state:
		State.ENEMIES_AND_GAMEPLAY:
			show_story_part()
		State.CONTROLS:
			show_enemies_part()


func show_story_part() -> void:
	$Panel/Story.show()
	$Panel/EnemiesAndGameplay.hide()
	$Panel/Controls.hide()
	$Panel/BackButton.hide()
	$Panel/NextButton.show()
	state = State.STORY


func show_enemies_part() -> void:
	$Panel/Story.hide()
	$Panel/EnemiesAndGameplay.show()
	$Panel/Controls.hide()
	$Panel/BackButton.show()
	$Panel/NextButton.show()
	state = State.ENEMIES_AND_GAMEPLAY


func show_controls_part() -> void:
	$Panel/Story.hide()
	$Panel/EnemiesAndGameplay.hide()
	$Panel/Controls.show()
	$Panel/BackButton.show()
	$Panel/NextButton.hide()
	state = State.CONTROLS
