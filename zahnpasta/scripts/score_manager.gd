class_name ScoreManager
extends Node

signal score_updated(score: int)


@export var base_score_per_beat: int = 10
@export var base_score_multiplier: float = 1.0
@export var extra_score_multiplier_per_intensity_level: float = 0.1
@export var rythm_manager: RythmManager


var _score: int = 0
var _multiplier: float


func _ready() -> void:
	rythm_manager.beat_hit.connect(self._on_rythm_manager_beat_hit)
	_multiplier = base_score_multiplier


func update_intensity(intensity: int) -> void:
	_multiplier = base_score_multiplier + intensity * extra_score_multiplier_per_intensity_level


func _on_rythm_manager_beat_hit(_beat: int) -> void:
	_score += base_score_per_beat * _multiplier
	score_updated.emit(_score)
