class_name ScoreManager
extends Node

signal score_updated(score: int)
signal multiplier_updated(multiplier: float)


@export var base_score_per_beat: int = 100
@export var base_score_multiplier: float = 1.0
@export var extra_score_multiplier_per_intensity_level: float = 0.1
@export var extra_score_multiplier_per_combo_level: float = 1.0
@export var rythm_manager: RythmManager


var _score: int = 0
var _multiplier: float
var _intensity_multiplier: float = 0.0
var _combo_multiplier: float = 0.0


func _ready() -> void:
	rythm_manager.beat_hit.connect(self._on_rythm_manager_beat_hit)
	_multiplier = base_score_multiplier


func update_intensity(intensity: int) -> void:
	_intensity_multiplier = intensity * extra_score_multiplier_per_intensity_level
	_update_multiplier()


func update_combo(combo: int) -> void:
	_combo_multiplier = combo * extra_score_multiplier_per_combo_level
	_update_multiplier()


func current_score() -> int:
	return _score


func _update_multiplier() -> void:
	_multiplier = base_score_multiplier + _intensity_multiplier + _combo_multiplier
	multiplier_updated.emit(_multiplier)


func _on_rythm_manager_beat_hit(_beat: int) -> void:
	_score += base_score_per_beat * _multiplier
	score_updated.emit(_score)
