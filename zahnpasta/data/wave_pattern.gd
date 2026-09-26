class_name WavePattern
extends Resource

@export var spawns_per_beat: Array[Spawns] = []

func beats_length() -> int:
	return spawns_per_beat.size()
