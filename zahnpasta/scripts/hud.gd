class_name HUD
extends CanvasLayer

@export var rythm_manager: RythmManager
@export var score_manager: ScoreManager


func _ready() -> void:
	rythm_manager.beat_hit.connect(self._on_rythm_manager_beat_hit)
	score_manager.score_updated.connect(self._on_score_manager_score_updated)


func _on_rythm_manager_beat_hit(beat: int) -> void:
	$BeatLabel.text = "Beat: %d" % beat


func _on_score_manager_score_updated(score: int) -> void:
	$ScoreLabel.text = "Score: %d" % score
