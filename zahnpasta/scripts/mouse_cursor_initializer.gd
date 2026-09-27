extends Node

var cursor = load("res://assets/cursor.png")
var pointer = load("res://assets/cursor_pointer.png")


func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor)
	Input.set_custom_mouse_cursor(pointer, Input.CURSOR_POINTING_HAND)
