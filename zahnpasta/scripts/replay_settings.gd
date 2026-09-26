extends Node

var is_replay: bool = false
var saved_history: Array[Snapshot] = []


func ready_to_play():
	is_replay = false


func set_history(new_history: Array[Snapshot]):
	saved_history = new_history


func set_to_replay():
	get_tree().paused = false
	is_replay = true
	get_tree().reload_current_scene()
