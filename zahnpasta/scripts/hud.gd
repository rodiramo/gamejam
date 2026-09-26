class_name HUD
extends CanvasLayer

signal menu_button_pressed

@export var rythm_manager: RythmManager
@export var score_manager: ScoreManager
@export var player: Player

@export var multiplier_label_base_font_size: int = 12

var health_segments: Array[HealthSegment] = []


func _ready() -> void:
	rythm_manager.beat_hit.connect(self._on_rythm_manager_beat_hit)
	score_manager.score_updated.connect(self._on_score_manager_score_updated)
	score_manager.multiplier_updated.connect(self._on_score_manager_multiplier_updated)
	player.health_updated.connect(self._on_player_health_updated)
	
	for child in $HealthSegments.get_children():
		health_segments.append(child)


func _on_rythm_manager_beat_hit(beat: int) -> void:
	$BeatLabel.text = "Beat: %d" % beat


func _on_score_manager_score_updated(score: int) -> void:
	$ScoreLabel.text = "Score: %d" % score


func _on_score_manager_multiplier_updated(multiplier: float) -> void:
	$MultiplierLabel.text = "x%d" % multiplier
	$MultiplierLabel.label_settings.font_size = clampi(multiplier_label_base_font_size + multiplier_label_base_font_size * multiplier * 0.1, multiplier_label_base_font_size, multiplier_label_base_font_size * 2)


func _on_player_health_updated(health: int, max_health: int) -> void:
	for i in range(max_health):
		if i < health:
			health_segments[i].reset()
		elif i == health:
			health_segments[i].lose()


func _on_menu_button_pressed() -> void:
	menu_button_pressed.emit()
