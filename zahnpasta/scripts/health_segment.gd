class_name HealthSegment
extends Control

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func reset() -> void:
	anim.set_frame_and_progress(0, 0.0)


func lose() -> void:
	anim.play("default")
