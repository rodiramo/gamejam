class_name MovementTracker
extends Node

var history: Array[Snapshot] = []
var start_height: int = 10

@export var rythem_manager: RythmManager
@export var player: Player
@export var game_end_overlay: GameEndedOverlay

func _ready() -> void:
	game_end_overlay.replay_pressed.connect(switch_to_replay)
	

func track_move(type: Snapshot.MoveType):
	var beat = rythem_manager.get_current_beat()
	if beat < 1:
		return
	if start_height == 10:
		start_height = player.get_pitch()
	
	var snapshot: Snapshot = Snapshot.new()
	snapshot.set_move_type(type)
	snapshot.set_beats(beat)
	
	if history.size() > 0:
		var last_snapshot = history[history.size() - 1]
		if last_snapshot.beat == beat:
			snapshot.set_in_between_time(rythem_manager.get_time_from_last_beat() - last_snapshot.in_between_time)
		else:
			snapshot.set_in_between_time(rythem_manager.get_time_from_last_beat())
	history.append(snapshot)


func track_up(dash: bool):
	print("Tracking Upwards")
	track_move(Snapshot.MoveType.DASH_UP if dash else Snapshot.MoveType.UP)


func track_down(dash: bool):
	print("Tracking Downwards")
	track_move(Snapshot.MoveType.DASH_DOWN if dash else Snapshot.MoveType.DOWN)


func switch_to_replay():
	get_tree().paused = false
	ReplaySettings.replay_mode(history)
	get_tree().reload_current_scene()
