class_name MovementTracker
extends Node

@export var rythem_manager: RythmManager

var history: Array[Snapshot] = []
var start_position: Vector2 = Vector2(0, 2)


func _ready() -> void:
	rythem_manager.beat_hit.connect(_on_beat)
	

func _on_beat(beat: int):
	pass


func track_move_to(pos: Vector2):
	var current_beat = rythem_manager.get_current_beat()
	if current_beat < 1:
		start_position = pos
	
	var snapshot = Snapshot.new()
	snapshot.to_position = pos
	snapshot.beat = current_beat
	snapshot.in_between_time = rythem_manager.get_time_since_beat()
	
	history.append(snapshot)
