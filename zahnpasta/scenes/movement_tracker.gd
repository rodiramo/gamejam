class_name MovementTracker
extends Node

var history: Array[Snapshot] = []

@export var rythem_manager: RythmManager


func track_move(type: Snapshot.MoveType):
	var snapshot: Snapshot = Snapshot.new()
	snapshot.set_move_type(type)
	snapshot.set_beats(rythem_manager.get_current_beat())
	snapshot.set_in_between_time(rythem_manager.get_time_from_last_beat())
	history.append(snapshot)


func track_up():
	track_move(Snapshot.MoveType.UP)


func track_down():
	track_move(Snapshot.MoveType.DOWN)
