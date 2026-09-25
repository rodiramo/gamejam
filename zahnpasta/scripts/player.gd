extends StaticBody2D

const STEP_SIZE = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		position.y -= STEP_SIZE
	if Input.is_action_just_pressed("down"):
		position.y += STEP_SIZE
