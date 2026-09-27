extends Node

var is_replay: bool = false
var saved_history: Array[Snapshot] = []


func ready_to_play() -> void:
	is_replay = false
	saved_history = []


func set_history(new_history: Array[Snapshot]) -> void:
	saved_history = new_history


func set_to_replay() -> void:
	get_tree().paused = false
	is_replay = true
	get_tree().reload_current_scene()


func get_for_beat(beat: int) -> Array[Snapshot]:
	if beat > saved_history[saved_history.size() - 1].beat:
		return []
	
	var snapshots: Array[Snapshot] = []
	for i in saved_history:
		if i.beat > beat:
			return snapshots
		
		if i.beat == beat:
			snapshots.append(i)
	
	return snapshots
