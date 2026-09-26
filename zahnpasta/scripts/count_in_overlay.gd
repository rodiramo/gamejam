extends CanvasLayer


func show_count(count: int) -> void:
	$Panel/CountLabel.text = "%d" % count
