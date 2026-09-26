class_name PauseOverlay
extends CanvasLayer

signal resume_pressed
signal back_to_main_menu_pressed


func _on_resume_button_pressed() -> void:
	resume_pressed.emit()


func _on_back_to_main_menu_button_pressed() -> void:
	back_to_main_menu_pressed.emit()
