class_name Bullet
extends Area2D

const NUM_DIFFERENT_SPRITES = 5

@export var movement = Vector2(-1, 0)

var _pos: Vector2
var _sprites: Array[AnimatedSprite2D] = []


func active_sprite(index: int) -> void:
	for child in get_children():
		if child.is_in_group("bullet_sprites"):
			_sprites.append(child)
	
	_sprites[index].show()


func get_pos() -> Vector2:
	return _pos

func move_to(grid_pos: Vector2, grid: Grid) -> bool:
	_pos = grid_pos
	return grid.move_to_grid(grid_pos, self)
	
func move(grid: Grid) -> bool:
	return move_to(_pos + movement, grid)
	
func move_to_spawn(lane: int, grid: Grid) -> void:
	move_to(grid.get_spawn_position(lane), grid)
