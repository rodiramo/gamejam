class_name HUD
extends CanvasLayer

@export var rythm_manager: RythmManager
@export var score_manager: ScoreManager
@export var player: Player


func _ready() -> void:
	rythm_manager.beat_hit.connect(self._on_rythm_manager_beat_hit)
	score_manager.score_updated.connect(self._on_score_manager_score_updated)
	score_manager.multiplier_updated.connect(self._on_score_manager_multiplier_updated)
	player.health_updated.connect(self._on_player_health_updated)


func _on_rythm_manager_beat_hit(beat: int) -> void:
	$BeatLabel.text = "Beat: %d" % beat


func _on_score_manager_score_updated(score: int) -> void:
	$ScoreLabel.text = "Score: %d" % score


func _on_score_manager_multiplier_updated(multiplier: float) -> void:
	$MultiplierLabel.text = "Multiplier: %.02fx" % multiplier


func _on_player_health_updated(health: int, max_health: int) -> void:
	$HealthLabel.text = "Health: %d/%d" % [health, max_health]
