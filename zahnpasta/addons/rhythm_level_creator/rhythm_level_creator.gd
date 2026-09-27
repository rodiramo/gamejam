@tool
extends VBoxContainer

const LEVEL_CONFIG_SCRIPT_PATH := "res://data/level_config.gd"
const BPM_SECTION_SCRIPT_PATH := "res://data/bpm_section.gd"
const WAVE_DIRECTORY := "res://data/wave_patterns"

const PATTERN_PREVIEW_SCRIPT = preload(
	"res://addons/rhythm_level_creator/pattern_preview.gd"
)

var current_level: Resource
var current_file_path := ""

var path_label: Label
var status_label: Label

var bpm_list: ItemList
var bpm_spin: SpinBox
var beat_spin: SpinBox

var library_list: ItemList
var sequence_list: ItemList
var preview: Control
var preview_name_label: Label

var total_bpm_label: Label
var total_wave_label: Label

var load_dialog: FileDialog
var save_dialog: FileDialog

var editing_bpm_controls := false


func _ready() -> void:
	custom_minimum_size = Vector2(390.0, 500.0)

	_build_interface()
	_create_file_dialogs()
	_refresh_wave_library()
	_new_level()


# -------------------------------------------------------------------
# Interface construction
# -------------------------------------------------------------------

func _build_interface() -> void:
	var title := Label.new()
	title.text = "Rhythm Level Creator"
	title.add_theme_font_size_override("font_size", 18)
	add_child(title)

	path_label = Label.new()
	path_label.text = "Unsaved level"
	path_label.tooltip_text = "Current level resource"
	path_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	add_child(path_label)

	var file_buttons := HBoxContainer.new()
	add_child(file_buttons)

	file_buttons.add_child(
		_make_button("New", _new_level)
	)
	file_buttons.add_child(
		_make_button("Load", _show_load_dialog)
	)
	file_buttons.add_child(
		_make_button("Save", _save_level)
	)
	file_buttons.add_child(
		_make_button("Save As", _show_save_dialog)
	)

	add_child(HSeparator.new())

	# BPM section editor.
	var bpm_header := Label.new()
	bpm_header.text = "BPM Sections"
	bpm_header.add_theme_font_size_override("font_size", 16)
	add_child(bpm_header)

	bpm_list = ItemList.new()
	bpm_list.custom_minimum_size = Vector2(0.0, 125.0)
	bpm_list.select_mode = ItemList.SELECT_SINGLE
	bpm_list.item_selected.connect(_on_bpm_section_selected)
	add_child(bpm_list)

	var bpm_edit_row := HBoxContainer.new()
	add_child(bpm_edit_row)

	var bpm_text := Label.new()
	bpm_text.text = "BPM"
	bpm_edit_row.add_child(bpm_text)

	bpm_spin = SpinBox.new()
	bpm_spin.min_value = 1.0
	bpm_spin.max_value = 999.0
	bpm_spin.step = 0.1
	bpm_spin.value = 120.0
	bpm_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bpm_spin.value_changed.connect(_on_bpm_changed)
	bpm_edit_row.add_child(bpm_spin)

	var beats_text := Label.new()
	beats_text.text = "Beats"
	bpm_edit_row.add_child(beats_text)

	beat_spin = SpinBox.new()
	beat_spin.min_value = 1.0
	beat_spin.max_value = 10000.0
	beat_spin.step = 1.0
	beat_spin.value = 16.0
	beat_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	beat_spin.value_changed.connect(_on_section_beats_changed)
	bpm_edit_row.add_child(beat_spin)

	var bpm_buttons := HBoxContainer.new()
	add_child(bpm_buttons)

	bpm_buttons.add_child(
		_make_button("+ Section", _add_bpm_section)
	)
	bpm_buttons.add_child(
		_make_button("Remove", _remove_bpm_section)
	)
	bpm_buttons.add_child(
		_make_button("Up", _move_bpm_section_up)
	)
	bpm_buttons.add_child(
		_make_button("Down", _move_bpm_section_down)
	)

	add_child(HSeparator.new())

	# Wave pattern section.
	var wave_header := Label.new()
	wave_header.text = "Wave Sequence"
	wave_header.add_theme_font_size_override("font_size", 16)
	add_child(wave_header)

	var lists := HSplitContainer.new()
	lists.custom_minimum_size = Vector2(0.0, 215.0)
	lists.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(lists)

	# Wave library.
	var library_box := VBoxContainer.new()
	library_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lists.add_child(library_box)

	var library_header := Label.new()
	library_header.text = "Pattern Library"
	library_box.add_child(library_header)

	library_list = ItemList.new()
	library_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	library_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	library_list.select_mode = ItemList.SELECT_SINGLE
	library_list.item_selected.connect(_on_library_selected)
	library_list.item_activated.connect(_on_library_activated)
	library_box.add_child(library_list)

	var refresh_button := _make_button(
		"Refresh Library",
		_refresh_wave_library
	)
	library_box.add_child(refresh_button)

	# Current sequence.
	var sequence_box := VBoxContainer.new()
	sequence_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lists.add_child(sequence_box)

	var sequence_header := Label.new()
	sequence_header.text = "Current Level"
	sequence_box.add_child(sequence_header)

	sequence_list = ItemList.new()
	sequence_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sequence_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sequence_list.select_mode = ItemList.SELECT_SINGLE
	sequence_list.item_selected.connect(_on_sequence_selected)
	sequence_list.item_activated.connect(_on_sequence_activated)
	sequence_box.add_child(sequence_list)

	var add_remove_row := HBoxContainer.new()
	sequence_box.add_child(add_remove_row)

	add_remove_row.add_child(
		_make_button("Add →", _add_selected_wave)
	)
	add_remove_row.add_child(
		_make_button("Remove", _remove_selected_wave)
	)
	add_remove_row.add_child(
		_make_button("Copy", _duplicate_selected_wave)
	)

	var move_row := HBoxContainer.new()
	sequence_box.add_child(move_row)

	move_row.add_child(
		_make_button("Up", _move_wave_up)
	)
	move_row.add_child(
		_make_button("Down", _move_wave_down)
	)

	# Pattern preview.
	add_child(HSeparator.new())

	preview_name_label = Label.new()
	preview_name_label.text = "Pattern Preview"
	preview_name_label.add_theme_font_size_override("font_size", 15)
	add_child(preview_name_label)

	preview = PATTERN_PREVIEW_SCRIPT.new()
	preview.custom_minimum_size = Vector2(0.0, 150.0)
	add_child(preview)

	var totals := HBoxContainer.new()
	add_child(totals)

	total_bpm_label = Label.new()
	total_bpm_label.text = "BPM beats: 0"
	total_bpm_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	totals.add_child(total_bpm_label)

	total_wave_label = Label.new()
	total_wave_label.text = "Wave beats: 0"
	total_wave_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	totals.add_child(total_wave_label)

	status_label = Label.new()
	status_label.text = "Ready"
	status_label.modulate = Color(0.7, 0.75, 0.8)
	add_child(status_label)


func _make_button(
	button_text: String,
	callback: Callable
) -> Button:
	var button := Button.new()
	button.text = button_text
	button.pressed.connect(callback)
	return button


func _create_file_dialogs() -> void:
	load_dialog = FileDialog.new()
	load_dialog.access = FileDialog.ACCESS_RESOURCES
	load_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	load_dialog.filters = PackedStringArray([
		"*.tres ; Godot Resource"
	])
	load_dialog.file_selected.connect(_load_level)
	add_child(load_dialog)

	save_dialog = FileDialog.new()
	save_dialog.access = FileDialog.ACCESS_RESOURCES
	save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_dialog.filters = PackedStringArray([
		"*.tres ; Godot Resource"
	])
	save_dialog.file_selected.connect(_save_level_as)
	add_child(save_dialog)


# -------------------------------------------------------------------
# Level files
# -------------------------------------------------------------------

func _new_level() -> void:
	var level_script: Script = load(LEVEL_CONFIG_SCRIPT_PATH)

	if level_script == null:
		_set_status(
			"Could not load %s" % LEVEL_CONFIG_SCRIPT_PATH,
			true
		)
		return

	current_level = level_script.new()
	current_file_path = ""

	path_label.text = "Unsaved level"

	_refresh_bpm_list()
	_refresh_sequence_list()

	_set_status("Created a new level")


func _show_load_dialog() -> void:
	load_dialog.popup_centered_ratio(0.75)


func _show_save_dialog() -> void:
	if current_file_path.is_empty():
		save_dialog.current_file = "new_level.tres"
	else:
		save_dialog.current_path = current_file_path

	save_dialog.popup_centered_ratio(0.75)


func _load_level(path: String) -> void:
	var loaded: Resource = ResourceLoader.load(
		path,
		"",
		ResourceLoader.CACHE_MODE_REPLACE
	)

	if loaded == null:
		_set_status("Could not load level: %s" % path, true)
		return

	if not _resource_has_property(loaded, "bpm_sections"):
		_set_status("Resource is not a LevelConfig", true)
		return

	if not _resource_has_property(loaded, "waves"):
		_set_status("Resource has no waves property", true)
		return

	current_level = loaded
	current_file_path = path
	path_label.text = path

	_refresh_bpm_list()
	_refresh_sequence_list()

	_set_status("Loaded %s" % path.get_file())


func _save_level() -> void:
	if current_level == null:
		_set_status("There is no level to save", true)
		return

	if current_file_path.is_empty():
		_show_save_dialog()
		return

	_write_level(current_file_path)


func _save_level_as(path: String) -> void:
	var final_path := path

	if final_path.get_extension().to_lower() != "tres":
		final_path += ".tres"

	current_file_path = final_path
	path_label.text = final_path

	_write_level(final_path)


func _write_level(path: String) -> void:
	current_level.emit_changed()

	var result := ResourceSaver.save(current_level, path)

	if result != OK:
		_set_status(
			"Save failed with error code %d" % result,
			true
		)
		return

	_set_status("Saved %s" % path.get_file())


# -------------------------------------------------------------------
# BPM sections
# -------------------------------------------------------------------

func _get_bpm_sections() -> Array:
	if current_level == null:
		return []

	var value: Variant = current_level.get("bpm_sections")

	if value is Array:
		return value

	return []


func _add_bpm_section() -> void:
	if current_level == null:
		return

	var bpm_script: Script = load(BPM_SECTION_SCRIPT_PATH)

	if bpm_script == null:
		_set_status(
			"Could not load %s" % BPM_SECTION_SCRIPT_PATH,
			true
		)
		return

	var section: Resource = bpm_script.new()
	section.set("bpm", bpm_spin.value)
	section.set("beats", int(beat_spin.value))

	var sections := _get_bpm_sections()
	sections.append(section)
	current_level.set("bpm_sections", sections)
	current_level.emit_changed()

	_refresh_bpm_list()

	var new_index := sections.size() - 1
	if new_index >= 0:
		bpm_list.select(new_index)
		_on_bpm_section_selected(new_index)

	_set_status("Added BPM section")


func _remove_bpm_section() -> void:
	var selected := bpm_list.get_selected_items()

	if selected.is_empty():
		return

	var index: int = selected[0]
	var sections := _get_bpm_sections()

	if index < 0 or index >= sections.size():
		return

	sections.remove_at(index)
	current_level.set("bpm_sections", sections)
	current_level.emit_changed()

	_refresh_bpm_list()
	_set_status("Removed BPM section")


func _move_bpm_section_up() -> void:
	_move_bpm_section(-1)


func _move_bpm_section_down() -> void:
	_move_bpm_section(1)


func _move_bpm_section(direction: int) -> void:
	var selected := bpm_list.get_selected_items()

	if selected.is_empty():
		return

	var old_index: int = selected[0]
	var new_index := old_index + direction
	var sections := _get_bpm_sections()

	if new_index < 0 or new_index >= sections.size():
		return

	var temporary: Variant = sections[old_index]
	sections[old_index] = sections[new_index]
	sections[new_index] = temporary

	current_level.set("bpm_sections", sections)
	current_level.emit_changed()

	_refresh_bpm_list()
	bpm_list.select(new_index)
	_on_bpm_section_selected(new_index)


func _on_bpm_section_selected(index: int) -> void:
	var sections := _get_bpm_sections()

	if index < 0 or index >= sections.size():
		return

	var section: Resource = sections[index]

	editing_bpm_controls = true
	bpm_spin.value = float(section.get("bpm"))
	beat_spin.value = int(section.get("beats"))
	editing_bpm_controls = false


func _on_bpm_changed(value: float) -> void:
	if editing_bpm_controls:
		return

	var selected := bpm_list.get_selected_items()

	if selected.is_empty():
		return

	var index: int = selected[0]
	var sections := _get_bpm_sections()

	if index < 0 or index >= sections.size():
		return

	var section: Resource = sections[index]
	section.set("bpm", value)
	section.emit_changed()
	current_level.emit_changed()

	_refresh_bpm_list()
	bpm_list.select(index)


func _on_section_beats_changed(value: float) -> void:
	if editing_bpm_controls:
		return

	var selected := bpm_list.get_selected_items()

	if selected.is_empty():
		return

	var index: int = selected[0]
	var sections := _get_bpm_sections()

	if index < 0 or index >= sections.size():
		return

	var section: Resource = sections[index]
	section.set("beats", int(value))
	section.emit_changed()
	current_level.emit_changed()

	_refresh_bpm_list()
	bpm_list.select(index)


func _refresh_bpm_list() -> void:
	if bpm_list == null:
		return

	bpm_list.clear()

	var total_beats := 0
	var sections := _get_bpm_sections()

	for index in range(sections.size()):
		var section: Resource = sections[index]
		var bpm := float(section.get("bpm"))
		var beats := int(section.get("beats"))

		total_beats += beats

		bpm_list.add_item(
			"%02d: %.1f BPM — %d beats" % [
				index + 1,
				bpm,
				beats
			]
		)

	if total_bpm_label != null:
		total_bpm_label.text = "BPM beats: %d" % total_beats

	_update_total_colors()


# -------------------------------------------------------------------
# Wave library
# -------------------------------------------------------------------

func _refresh_wave_library() -> void:
	if library_list == null:
		return

	library_list.clear()

	var paths: Array[String] = []
	_collect_tres_files(WAVE_DIRECTORY, paths)
	paths.sort()

	for path in paths:
		var wave: Resource = load(path)

		if wave == null:
			continue

		if not _resource_has_property(wave, "spawns_per_beat"):
			continue

		var beat_count := _get_wave_beat_count(wave)
		var display_name := path.get_file().get_basename()

		var item_index := library_list.add_item(
			"%s  (%d)" % [display_name, beat_count]
		)

		library_list.set_item_metadata(item_index, wave)
		library_list.set_item_tooltip(
			item_index,
			path
		)

	_set_status(
		"Found %d wave patterns" % library_list.item_count
	)


func _collect_tres_files(
	directory_path: String,
	output: Array[String]
) -> void:
	var directory := DirAccess.open(directory_path)

	if directory == null:
		return

	directory.list_dir_begin()

	while true:
		var file_name := directory.get_next()

		if file_name.is_empty():
			break

		if file_name.begins_with("."):
			continue

		var full_path := directory_path.path_join(file_name)

		if directory.current_is_dir():
			_collect_tres_files(full_path, output)
		elif file_name.get_extension().to_lower() == "tres":
			output.append(full_path)

	directory.list_dir_end()


func _on_library_selected(index: int) -> void:
	var wave: Resource = library_list.get_item_metadata(index)
	_show_pattern(wave)


func _on_library_activated(_index: int) -> void:
	_add_selected_wave()


# -------------------------------------------------------------------
# Wave sequence
# -------------------------------------------------------------------

func _get_waves() -> Array:
	if current_level == null:
		return []

	var value: Variant = current_level.get("waves")

	if value is Array:
		return value

	return []


func _add_selected_wave() -> void:
	var selected := library_list.get_selected_items()

	if selected.is_empty():
		_set_status("Select a pattern from the library", true)
		return

	var library_index: int = selected[0]
	var wave: Resource = library_list.get_item_metadata(
		library_index
	)

	if wave == null:
		return

	var waves := _get_waves()

	# Insert after the selected sequence item, otherwise append.
	var sequence_selection := sequence_list.get_selected_items()
	var insert_index := waves.size()

	if not sequence_selection.is_empty():
		insert_index = int(sequence_selection[0]) + 1

	waves.insert(insert_index, wave)
	current_level.set("waves", waves)
	current_level.emit_changed()

	_refresh_sequence_list()
	sequence_list.select(insert_index)
	_on_sequence_selected(insert_index)

	_set_status("Added %s" % wave.resource_path.get_file())


func _remove_selected_wave() -> void:
	var selected := sequence_list.get_selected_items()

	if selected.is_empty():
		return

	var index: int = selected[0]
	var waves := _get_waves()

	if index < 0 or index >= waves.size():
		return

	waves.remove_at(index)
	current_level.set("waves", waves)
	current_level.emit_changed()

	_refresh_sequence_list()

	if not waves.is_empty():
		var next_index: int = min(index, waves.size() - 1)
		sequence_list.select(next_index)
		_on_sequence_selected(next_index)

	_set_status("Removed wave")


func _duplicate_selected_wave() -> void:
	var selected := sequence_list.get_selected_items()

	if selected.is_empty():
		return

	var index: int = selected[0]
	var waves := _get_waves()

	if index < 0 or index >= waves.size():
		return

	waves.insert(index + 1, waves[index])
	current_level.set("waves", waves)
	current_level.emit_changed()

	_refresh_sequence_list()
	sequence_list.select(index + 1)
	_on_sequence_selected(index + 1)

	_set_status("Duplicated wave")


func _move_wave_up() -> void:
	_move_wave(-1)


func _move_wave_down() -> void:
	_move_wave(1)


func _move_wave(direction: int) -> void:
	var selected := sequence_list.get_selected_items()

	if selected.is_empty():
		return

	var old_index: int = selected[0]
	var new_index := old_index + direction
	var waves := _get_waves()

	if new_index < 0 or new_index >= waves.size():
		return

	var temporary: Variant = waves[old_index]
	waves[old_index] = waves[new_index]
	waves[new_index] = temporary

	current_level.set("waves", waves)
	current_level.emit_changed()

	_refresh_sequence_list()
	sequence_list.select(new_index)
	_on_sequence_selected(new_index)


func _on_sequence_selected(index: int) -> void:
	var waves := _get_waves()

	if index < 0 or index >= waves.size():
		return

	_show_pattern(waves[index])


func _on_sequence_activated(_index: int) -> void:
	_duplicate_selected_wave()


func _refresh_sequence_list() -> void:
	if sequence_list == null:
		return

	sequence_list.clear()

	var waves := _get_waves()
	var total_wave_beats := 0
	var running_beat := 0

	for index in range(waves.size()):
		var wave: Resource = waves[index]
		var wave_beats := _get_wave_beat_count(wave)
		var wave_name := _get_wave_name(wave)

		total_wave_beats += wave_beats

		var item_index := sequence_list.add_item(
			"%02d: %s  [%d–%d]" % [
				index + 1,
				wave_name,
				running_beat,
				running_beat + wave_beats
			]
		)

		sequence_list.set_item_metadata(item_index, wave)

		if not wave.resource_path.is_empty():
			sequence_list.set_item_tooltip(
				item_index,
				wave.resource_path
			)

		running_beat += wave_beats

	if total_wave_label != null:
		total_wave_label.text = "Wave beats: %d" % total_wave_beats

	_update_total_colors()


# -------------------------------------------------------------------
# Preview and totals
# -------------------------------------------------------------------

func _show_pattern(wave: Resource) -> void:
	preview.pattern = wave

	if wave == null:
		preview_name_label.text = "Pattern Preview"
		return

	preview_name_label.text = "%s — %d beats" % [
		_get_wave_name(wave),
		_get_wave_beat_count(wave)
	]


func _get_wave_name(wave: Resource) -> String:
	if wave == null:
		return "Missing Pattern"

	if not wave.resource_path.is_empty():
		return wave.resource_path.get_file().get_basename()

	return "Embedded Pattern"


func _get_wave_beat_count(wave: Resource) -> int:
	if wave == null:
		return 0

	var value: Variant = wave.get("spawns_per_beat")

	if value is Array:
		return value.size()

	return 0


func _get_total_bpm_beats() -> int:
	var total := 0

	for section in _get_bpm_sections():
		if section != null:
			total += int(section.get("beats"))

	return total


func _get_total_wave_beats() -> int:
	var total := 0

	for wave in _get_waves():
		total += _get_wave_beat_count(wave)

	return total


func _update_total_colors() -> void:
	if total_bpm_label == null or total_wave_label == null:
		return

	var bpm_total := _get_total_bpm_beats()
	var wave_total := _get_total_wave_beats()

	var matching_color := Color(0.35, 1.0, 0.5)
	var mismatching_color := Color(1.0, 0.55, 0.3)
	var neutral_color := Color(0.8, 0.82, 0.85)

	if bpm_total == 0 and wave_total == 0:
		total_bpm_label.modulate = neutral_color
		total_wave_label.modulate = neutral_color
	elif bpm_total == wave_total:
		total_bpm_label.modulate = matching_color
		total_wave_label.modulate = matching_color
	else:
		total_bpm_label.modulate = mismatching_color
		total_wave_label.modulate = mismatching_color


# -------------------------------------------------------------------
# Helpers
# -------------------------------------------------------------------

func _resource_has_property(
	resource: Object,
	property_name: String
) -> bool:
	if resource == null:
		return false

	for property_data in resource.get_property_list():
		if String(property_data.name) == property_name:
			return true

	return false


func _set_status(message: String, is_error := false) -> void:
	if status_label == null:
		return

	status_label.text = message

	if is_error:
		status_label.modulate = Color(1.0, 0.35, 0.3)
	else:
		status_label.modulate = Color(0.7, 0.8, 0.9)
