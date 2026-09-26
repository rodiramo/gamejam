class_name BulletManager
extends Node

@export var grid: Grid
@export var _rythem_manager: RythmManager
@export var bullet_scene: PackedScene

var _level_config: LevelConfig
var _bullets: Array[Bullet] = []
var _current_wave = 0
var _current_beat_in_wave = 0

func _ready() -> void:
	_rythem_manager.beat_hit.connect(on_beat)

func initialize(level_config: LevelConfig) -> void:
	_level_config = level_config

func spawn_bullet(lane: int) -> void:
	var bullet: Bullet = bullet_scene.instantiate()
	self.add_child(bullet)
	bullet.move_to_spawn(lane, grid)
	_bullets.append(bullet)

func _spawn_new_bullets() -> void:
	var wave_segment = _get_current_beat_in_wave()
	if wave_segment == null:
		return

	for i in wave_segment.spawns_on_spawner.size():
		if wave_segment.spawns_on_spawner[i] == Spawns.BulletType.BULLET:
			spawn_bullet(i)

func _move_bullets() -> void:
	var to_delete: Array[int] = []
	
	for i in _bullets.size():
		if !_bullets[i].move(grid):
			to_delete.append(i)
	
	to_delete.reverse()
	for i in to_delete:
		_bullets[i].queue_free()
		_bullets.pop_at(i)

func _get_current_beat_in_wave() -> Spawns:
	if _current_wave > _level_config.waves.size() - 1:
		return null
	
	var wave = _level_config.waves[_current_wave]
	var current_beat = wave.spawns_per_beat[_current_beat_in_wave]
	if _current_beat_in_wave >= wave.beats_length() - 1:
		_current_wave += 1
		_current_beat_in_wave = 0
	else:
		_current_beat_in_wave += 1
	
	return current_beat

func on_beat(beat: int):
	_spawn_new_bullets()
	_move_bullets()
