class_name RythmManager
extends Node

signal beat_hit(beat: int)
signal level_ended

const ONE_MINUTE = 60.0

var _current_beat_interval_sec: float = 1.0
var _current_beat: int = 0
var _current_bpm_section: int = 0
var _beats_before_current_section: int = 0
var _level_config: LevelConfig


func initialize(level_config: LevelConfig) -> void:
	_level_config = level_config
	_current_beat = 0
	_current_bpm_section = 0
	_beats_before_current_section = 0
	self._set_beat_interval_from_current_bpm_section()


func start() -> void:
	$Timer.start(_current_beat_interval_sec)


func stop() -> void:
	$Timer.stop()


func process_beat() -> void:
	_current_beat += 1
	
	beat_hit.emit(_current_beat)
	
	if _should_change_bpm_section():
		if _has_next_bpm_section():
			_change_to_next_bpm_section()
		else:
			stop()
			level_ended.emit()


func _has_next_bpm_section() -> bool:
	return _current_bpm_section < _level_config.bpm_sections.size() - 1


func _should_change_bpm_section() -> bool:
	return _level_config.bpm_sections[_current_bpm_section].beats + _beats_before_current_section <= _current_beat


func _change_to_next_bpm_section() -> void:
	_beats_before_current_section = _current_beat
	_current_bpm_section += 1
	self._set_beat_interval_from_current_bpm_section()


func _set_beat_interval_from_current_bpm_section() -> void:
	_current_beat_interval_sec = ONE_MINUTE / _level_config.bpm_sections[_current_bpm_section].bpm
	$Timer.wait_time = _current_beat_interval_sec


func _on_timer_timeout() -> void:
	self.process_beat()
