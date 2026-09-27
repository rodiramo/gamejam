@tool
extends EditorPlugin

const CREATOR_SCRIPT = preload(
	"res://addons/rhythm_level_creator/rhythm_level_creator.gd"
)

var creator_dock: Control


func _enter_tree() -> void:
	creator_dock = CREATOR_SCRIPT.new()
	creator_dock.name = "Rhythm Level Creator"

	add_control_to_dock(
		EditorPlugin.DOCK_SLOT_RIGHT_UL,
		creator_dock
	)


func _exit_tree() -> void:
	if creator_dock != null:
		remove_control_from_docks(creator_dock)
		creator_dock.queue_free()
		creator_dock = null
