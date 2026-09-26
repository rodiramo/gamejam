class_name HUD
extends CanvasLayer

@export var rythm_manager: RythmManager


func _ready() -> void:
	rythm_manager.beat_hit.connect(self._on_rythm_manager_beat_hit)


func _on_rythm_manager_beat_hit(beat: int) -> void:
	$BeatLabel.text = "Beat: %d" % beat
