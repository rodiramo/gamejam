class_name Grid
extends Node2D

@export var width = 48
@export var height = 48
@export var cells_x = 10
@export var cells_y = 5

@export var grid_zero_marker: Marker2D

var random = RandomNumberGenerator.new()

func grid_pos_to_coordinats(grid_pos: Vector2):
	return grid_zero_marker.global_position + (grid_pos * Vector2(width, height))

func in_grid(grid_pos: Vector2) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < cells_x and grid_pos.y >= 0 and grid_pos.y < cells_y

## takes the desired grid pos as Vectro2 and the Node2D to move. Returns a bool of how successful the movement was.
func move_to_grid(grid_pos: Vector2, node: Node2D) -> bool: 
	if in_grid(grid_pos):
		node.global_position = grid_pos_to_coordinats(grid_pos)
		return true
	else:
		return false
