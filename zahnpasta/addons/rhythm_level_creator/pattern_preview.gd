@tool
extends Control

var pattern: Resource:
	set(value):
		pattern = value
		queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(300.0, 150.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var background := Color(0.055, 0.06, 0.075, 1.0)
	var grid_color := Color(0.25, 0.27, 0.32, 1.0)
	var active_color := Color(0.15, 0.78, 1.0, 1.0)
	var active_border := Color(0.65, 0.93, 1.0, 1.0)

	draw_rect(Rect2(Vector2.ZERO, size), background, true)

	var beat_spawns: Array = []

	if pattern != null:
		var value: Variant = pattern.get("spawns_per_beat")
		if value is Array:
			beat_spawns = value

	var beat_count: int = max(beat_spawns.size(), 1)
	var lane_count := 5

	var cell_width: float = size.x / float(beat_count)
	var cell_height: float = size.y / float(lane_count)

	# Alternating lane backgrounds.
	for lane in range(lane_count):
		if lane % 2 == 0:
			var lane_rect := Rect2(
				0.0,
				lane * cell_height,
				size.x,
				cell_height
			)
			draw_rect(
				lane_rect,
				Color(0.075, 0.08, 0.1, 1.0),
				true
			)

	# Grid.
	for beat in range(beat_count + 1):
		var x := beat * cell_width
		draw_line(
			Vector2(x, 0.0),
			Vector2(x, size.y),
			grid_color,
			1.0
		)

	for lane in range(lane_count + 1):
		var y := lane * cell_height
		draw_line(
			Vector2(0.0, y),
			Vector2(size.x, y),
			grid_color,
			1.0
		)

	if pattern == null:
		return

	# Spawn cells.
	for beat_index in range(beat_spawns.size()):
		var spawn_resource: Resource = beat_spawns[beat_index]

		if spawn_resource == null:
			continue

		var lane_values: Variant = spawn_resource.get(
			"spawns_on_spawner"
		)

		if not lane_values is Array:
			continue

		var lanes: Array = lane_values

		for lane_index in range(min(lanes.size(), lane_count)):
			if int(lanes[lane_index]) == 0:
				continue

			var padding := 3.0

			var spawn_rect := Rect2(
				beat_index * cell_width + padding,
				lane_index * cell_height + padding,
				max(cell_width - padding * 2.0, 1.0),
				max(cell_height - padding * 2.0, 1.0)
			)

			draw_rect(spawn_rect, active_color, true)
			draw_rect(spawn_rect, active_border, false, 1.5)
