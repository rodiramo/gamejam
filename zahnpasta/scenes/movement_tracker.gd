class_name MovementTracker
extends Node

@export var rythem_manager: RythmManager
@export var grid: Grid
@export var player: Player

var history: Array[Snapshot] = []
var start_position: Vector2 = Vector2(0, 2)


func _ready() -> void:
	rythem_manager.beat_hit.connect(_on_beat)
	

func _on_beat(beat: int):
	var snapshots = ReplaySettings.get_for_beat(beat)
	if snapshots.is_empty():
		return
	history = snapshots
	
	for snapshot in snapshots:
		var timer: Timer = Timer.new()
		timer.one_shot = true
		timer.timeout.connect(_on_timer_timeout)
		self.add_child(timer)
		timer.start(snapshot.in_between_time)


func _on_timer_timeout():
	var first_timer = self.get_children()[0]
	first_timer.queue_free()
	
	var snapshot = history[0]
	history.pop_at(0)
	
	grid.move_to_grid(snapshot.to_position, player)


func track_move_to(pos: Vector2):
	var current_beat = rythem_manager.get_current_beat()
	if current_beat < 1:
		start_position = pos
	
	var snapshot = Snapshot.new()
	snapshot.to_position = pos
	snapshot.beat = current_beat
	snapshot.in_between_time = rythem_manager.get_time_since_beat()
	
	history.append(snapshot)


func get_history():
	return history
