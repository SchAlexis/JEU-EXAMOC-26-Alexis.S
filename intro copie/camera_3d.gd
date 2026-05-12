extends Camera3D

var tilt = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input = Vector3.ZERO
	input.x = Input.get_axis('move_left', 'move_right')
	input.y = Input.get_axis('move_down', 'move_up')
	input.z = Input.get_axis('move_backward', 'move_forward')
	position += basis * input * 0.1


	var dir = Vector2.ZERO
	dir.x = Input.get_axis("ui_left", "ui_right")
	dir.y = Input.get_axis("ui_down", "ui_up")
	
	if dir:
		tilt += dir * 0.05
		tilt.y = clamp(-PI/2, tilt.y, PI/2)
		basis = Basis()
		rotation.y = tilt.x
		rotation.x = tilt.y
		print(tilt)
