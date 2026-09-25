class_name RythmManager
extends Node

signal beat_hit(beat: int)

var _current_beat_interval_sec: float = 1.0
var _current_beat: int = 0


func _ready() -> void:
	# TODO: load level/music configuration
	pass


func start() -> void:
	$Timer.start(_current_beat_interval_sec)


func stop() -> void:
	$Timer.stop()


func process_beat() -> void:
	_current_beat += 1
	# TODO: change beat interval if level config says so
	beat_hit.emit(_current_beat)


func _on_timer_timeout() -> void:
	self.process_beat()
