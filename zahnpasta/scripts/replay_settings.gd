extends Node

var player_controlled: bool = true
var history: Array[Snapshot] = []
var current_snapshot: int = 0


func ready_to_play():
	player_controlled = true
	history = []
	current_snapshot = 0


func replay_mode(new_history: Array[Snapshot]):
	if player_controlled:
		player_controlled = false
		history = new_history


func _get_all_in_beat_starting(first_index: int, beat: int):
	var snapshots: Array[Snapshot] = []
	for i in history.size() - first_index:
		if !history[i + first_index].beat == beat:
			return snapshots
		
		snapshots.append(history[i + first_index])
	
	return snapshots
	


func get_next_snapshot_batch() -> Array[Snapshot]:
	if current_snapshot >= history.size(): 
		return []
	
	print("Getting Snapshot batch")
	var beat = history[current_snapshot].beat
	var snapshots = _get_all_in_beat_starting(current_snapshot, beat)
	
	print("Got a Batch of: ", snapshots.size())
	current_snapshot += snapshots.size()
	
	return snapshots
	
