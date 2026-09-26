class_name PlayerController
extends Node

@onready var timer: Timer = $Timer

@export var player: Player
@export var movement_tracker: MovementTracker
@export var rythem_manager: RythmManager

var current_snapshots: Array[Snapshot]
var current_snapshot_in_batch: int
var current_snapshots_beat: int

func _ready() -> void:
	if !ReplaySettings.player_controlled:
		print()
		print()
		print()
		print("Starting Replay")
		print("Not player Controlled anymore")
		print("History size: ", ReplaySettings.history.size())
		
		current_snapshots = ReplaySettings.get_next_snapshot_batch()
		current_snapshot_in_batch = 0
		current_snapshots_beat = current_snapshots[0].beat
		print("Current batch size: ", current_snapshots.size())
		print("Current batch first beat: ", current_snapshots_beat)
		
		rythem_manager.beat_hit.connect(on_beat)
		timer.timeout.connect(_on_timer_timeout)


func _process(_delta: float) -> void:
	if ReplaySettings.player_controlled:
		var dash = true if Input.is_action_pressed("double_step") else false
		if Input.is_action_just_pressed("up"):
			print("Move UP: ", "HIGH" if dash else "")
			player.move(1, dash)
			movement_tracker.track_up(dash)
		elif Input.is_action_just_pressed("down"):
			print("Move DOWN: ", "HIGH" if dash else "")
			player.move(-1, dash)
			movement_tracker.track_down(dash)


func on_beat(beat: int):
	print("Beat it! ", beat)
	if current_snapshots_beat == beat:
		print("Been Beaten")
		timer.start(current_snapshots[current_snapshot_in_batch].in_between_time)


func _on_timer_timeout() -> void:
	timer.stop()
	match current_snapshots[current_snapshot_in_batch].move_type:
		Snapshot.MoveType.UP:
			player.move(1, false)
		Snapshot.MoveType.DASH_UP:
			player.move(1, true)
		Snapshot.MoveType.DOWN:
			player.move(-1, false)
		Snapshot.MoveType.DASH_DOWN:
			player.move(-1, true)
	
	if current_snapshots.size() -1 > current_snapshot_in_batch:
		current_snapshot_in_batch += 1
		timer.start(current_snapshots[current_snapshot_in_batch].in_between_time)
	else:
		current_snapshot_in_batch = 0
		current_snapshots = ReplaySettings.get_next_snapshot_batch()
		if current_snapshots.size() > 0:
			current_snapshots_beat = current_snapshots[0].beat
