class_name Spawns
extends Resource

enum BulletType {
	NONE,
	BULLET
}

@export var spawns_on_spawner: Array[BulletType] = [BulletType.NONE, BulletType.NONE, BulletType.NONE, BulletType.NONE, BulletType.NONE]
