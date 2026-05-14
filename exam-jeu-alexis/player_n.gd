# Attache ce script sur le noeud racine "PlayerN"
extends CharacterBody3D

# --- Paramètres ---
@export var speed := 5.0
@export var sprint_speed := 9.0
@export var jump_velocity := 5.0
@export var mouse_sensitivity := 0.002
@export var pitch_limit := 80.0  # degrés max vers le haut/bas

# --- Références ---
@onready var twist_pivot = $TwistPivot          # rotation gauche/droite
@onready var pitch_pivot = $TwistPivot/PitchPivot  # rotation haut/bas

var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	# Capture la souris au démarrage
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	# Mouvement caméra via souris
	if event is InputEventMouseMotion:
		# Gauche / Droite → rotation du TwistPivot
		twist_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		# Haut / Bas → rotation du PitchPivot (limité)
		pitch_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		pitch_pivot.rotation.x = clamp(
			pitch_pivot.rotation.x,
			deg_to_rad(-pitch_limit),
			deg_to_rad(pitch_limit)
		)
	
	# Echap pour libérer/recapturer la souris
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# --- Gravité ---
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# --- Saut ---
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# --- Déplacement WASD ---
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# Direction relative à l'orientation de la caméra (TwistPivot)
	var direction = (
		twist_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	# Sprint avec Shift
	var current_speed = sprint_speed if Input.is_action_pressed("sprint") else speed

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		# Décélération progressive
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
