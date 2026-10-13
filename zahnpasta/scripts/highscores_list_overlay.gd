extends CanvasLayer

signal closed


@onready var list: Node = $Panel/ScrollContainer/List

var list_item_scene: PackedScene = preload("res://scenes/highscore_list_item.tscn")


func _ready() -> void:
	Highscores.scores_updated.connect(_on_highscores_scores_updated)
	_clear_and_fill_list(Highscores.scores)
	Highscores.refresh_scores()


func _clear_and_fill_list(scores: Array[HighscoreEntry]) -> void:
	for old_entry in list.get_children():
		old_entry.queue_free()

	for entry in scores:
		var list_item = list_item_scene.instantiate()
		list.add_child(list_item)
		list_item.initialize(entry)


func _on_close_button_pressed() -> void:
	closed.emit()


func _on_highscores_scores_updated(scores: Array[HighscoreEntry]) -> void:
	_clear_and_fill_list(scores)


func _on_refresh_button_pressed() -> void:
	Highscores.refresh_scores()
