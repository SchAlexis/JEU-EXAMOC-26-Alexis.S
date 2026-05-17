@tool
extends CSGBox3D
class_name ServerRack

## Nœud ServerRack — rack de serveur détaillé pour la scène Data Center.
## Instanciable en masse via instantiate.gd ou directement depuis la scène.


# ──────────────────────────────────────────────
#  EXPORT — modifiables dans l'Inspector
# ──────────────────────────────────────────────

@export var rack_size := Vector3(1.0, 2.4, 0.8):
	set(value):
		rack_size = value
		create()

@export var wall_thickness := 0.04:
	set(value):
		wall_thickness = value
		create()

@export var num_units := 12:           ## Nombre de "tranches" serveur (1U chacune)
	set(value):
		num_units = clamp(value, 2, 20)
		create()

@export var rack_color := Color(0.08, 0.08, 0.10):
	set(value):
		rack_color = value
		_apply_materials()

@export var led_color := Color(0.0, 1.0, 0.4):  ## Couleur LEDs actives
	set(value):
		led_color = value
		_apply_materials()

@export var screen_color := Color(0.05, 0.3, 0.9): ## Couleur écrans LCD
	set(value):
		screen_color = value
		_apply_materials()

@export var cable_color := Color(0.05, 0.05, 0.4):
	set(value):
		cable_color = value
		_apply_materials()

@export_tool_button("Rebuild") var action = create


# ──────────────────────────────────────────────
#  MATÉRIAUX (créés une seule fois)
# ──────────────────────────────────────────────

var _mat_rack    : StandardMaterial3D
var _mat_led     : StandardMaterial3D
var _mat_screen  : StandardMaterial3D
var _mat_cable   : StandardMaterial3D
var _mat_steel   : StandardMaterial3D
var _mat_dark    : StandardMaterial3D


func _make_materials() -> void:
	_mat_rack = StandardMaterial3D.new()
	_mat_rack.albedo_color = rack_color
	_mat_rack.metallic = 0.8
	_mat_rack.roughness = 0.5

	_mat_led = StandardMaterial3D.new()
	_mat_led.albedo_color = led_color
	_mat_led.emission_enabled = true
	_mat_led.emission = led_color
	_mat_led.emission_energy_multiplier = 3.0

	_mat_screen = StandardMaterial3D.new()
	_mat_screen.albedo_color = screen_color
	_mat_screen.emission_enabled = true
	_mat_screen.emission = screen_color
	_mat_screen.emission_energy_multiplier = 1.5

	_mat_cable = StandardMaterial3D.new()
	_mat_cable.albedo_color = cable_color
	_mat_cable.roughness = 0.9

	_mat_steel = StandardMaterial3D.new()
	_mat_steel.albedo_color = Color(0.25, 0.25, 0.28)
	_mat_steel.metallic = 0.9
	_mat_steel.roughness = 0.3

	_mat_dark = StandardMaterial3D.new()
	_mat_dark.albedo_color = Color(0.05, 0.05, 0.06)
	_mat_dark.metallic = 0.4
	_mat_dark.roughness = 0.7


func _apply_materials() -> void:
	if _mat_rack == null:
		return
	_mat_rack.albedo_color   = rack_color
	_mat_led.albedo_color    = led_color
	_mat_led.emission        = led_color
	_mat_screen.albedo_color = screen_color
	_mat_screen.emission     = screen_color
	_mat_cable.albedo_color  = cable_color


# ──────────────────────────────────────────────
#  CYCLE DE VIE
# ──────────────────────────────────────────────

func _ready() -> void:
	create()


## Reconstruit entièrement le rack (supprime les anciens enfants procéduraux).
func create() -> void:
	_make_materials()
	_clear_procedural_children()
	_build_chassis()
	_build_server_units()
	_build_cable_tray()
	_build_feet()
	_build_top_fan_grille()


func _clear_procedural_children() -> void:
	for child in get_children():
		if child.owner == null:
			child.queue_free()


# ──────────────────────────────────────────────
#  CHÂSSIS PRINCIPAL (boîte creuse)
# ──────────────────────────────────────────────

func _build_chassis() -> void:
	# Boîte extérieure = le nœud racine lui-même
	size     = rack_size
	material = _mat_rack

	# Paroi avant (soustraction → ouverture pour voir les serveurs)
	var front_hole := CSGBox3D.new()
	front_hole.operation = CSGShape3D.OPERATION_SUBTRACTION
	front_hole.size = Vector3(
		rack_size.x - wall_thickness * 4,
		rack_size.y - wall_thickness * 4,
		wall_thickness * 3          # juste assez pour percer la face avant
	)
	front_hole.position = Vector3(0.0, 0.0, rack_size.z * 0.5)
	add_child(front_hole)

	# Paroi arrière (soustraction partielle — laisse un cadre)
	var back_hole := CSGBox3D.new()
	back_hole.operation = CSGShape3D.OPERATION_SUBTRACTION
	back_hole.size = Vector3(
		rack_size.x - wall_thickness * 6,
		rack_size.y - wall_thickness * 6,
		wall_thickness * 2
	)
	back_hole.position = Vector3(0.0, 0.0, -rack_size.z * 0.5)
	add_child(back_hole)

	# Rails verticaux intérieurs (gauche + droite)
	for side in [-1, 1]:
		var rail := CSGBox3D.new()
		rail.size = Vector3(wall_thickness * 1.5, rack_size.y - 0.02, wall_thickness * 1.5)
		rail.position = Vector3(side * (rack_size.x * 0.5 - wall_thickness * 2), 0.0, 0.0)
		rail.material = _mat_steel
		add_child(rail)


# ──────────────────────────────────────────────
#  TRANCHES SERVEUR (1U chacune)
# ──────────────────────────────────────────────

func _build_server_units() -> void:
	var unit_height := (rack_size.y - wall_thickness * 4) / float(num_units)
	var start_y    := -(rack_size.y * 0.5) + wall_thickness * 2 + unit_height * 0.5

	for i in num_units:
		var y := start_y + i * unit_height
		_build_one_unit(i, y, unit_height)


func _build_one_unit(index: int, y: float, unit_h: float) -> void:
	var gap    := 0.004
	var u_w    := rack_size.x - wall_thickness * 6
	var u_d    := rack_size.z - wall_thickness * 3
	var u_h    := unit_h - gap * 2
	var front_z := rack_size.z * 0.5 - wall_thickness * 1.5

	# Corps de l'unité
	var body := CSGBox3D.new()
	body.size     = Vector3(u_w, u_h, u_d)
	body.position = Vector3(0.0, y, 0.0)
	body.material = _mat_dark
	add_child(body)

	# ── Face avant ──
	# Panneau façade (légèrement en avant)
	var faceplate := CSGBox3D.new()
	faceplate.size     = Vector3(u_w, u_h, 0.012)
	faceplate.position = Vector3(0.0, y, front_z)
	faceplate.material = _mat_rack
	add_child(faceplate)

	# Écran LCD (petit, sur la gauche de la façade)
	var screen := CSGBox3D.new()
	screen.size     = Vector3(u_w * 0.22, u_h * 0.5, 0.005)
	screen.position = Vector3(-u_w * 0.28, y, front_z + 0.013)
	screen.material = _mat_screen
	add_child(screen)

	# LEDs (1 ou 2 selon l'index)
	var led_colors_list := [led_color, Color(1.0, 0.3, 0.0), Color(1.0, 0.0, 0.0)]
	var active_led_mat := _mat_led

	if index % 5 == 0:   # Quelques serveurs avec LED orange ou rouge
		active_led_mat = StandardMaterial3D.new()
		active_led_mat.albedo_color    = led_colors_list[index % 3]
		active_led_mat.emission_enabled = true
		active_led_mat.emission        = led_colors_list[index % 3]
		active_led_mat.emission_energy_multiplier = 3.0

	for l in 2:
		var led := CSGBox3D.new()
		led.size     = Vector3(0.012, 0.012, 0.005)
		led.position = Vector3(u_w * 0.1 + l * 0.025, y, front_z + 0.013)
		led.material = active_led_mat
		add_child(led)

	# Bouton power (petit cylindre simulé en CSG box ronde)
	var btn := CSGBox3D.new()
	btn.size     = Vector3(0.018, 0.018, 0.006)
	btn.position = Vector3(u_w * 0.38, y, front_z + 0.013)
	btn.material = _mat_steel
	add_child(btn)

	# Grille de ventilation sur la façade (fentes horizontales)
	if u_h > 0.06:
		for s in 3:
			var slot := CSGBox3D.new()
			slot.operation = CSGShape3D.OPERATION_SUBTRACTION
			slot.size      = Vector3(u_w * 0.25, u_h * 0.06, 0.018)
			slot.position  = Vector3(u_w * 0.15, y + (s - 1) * u_h * 0.25, front_z)
			add_child(slot)

	# ── Face arrière : connecteurs ──
	var back_z := -rack_size.z * 0.5 + wall_thickness * 1.5
	for c in 4:
		var connector := CSGBox3D.new()
		connector.size     = Vector3(0.025, 0.018, 0.015)
		connector.position = Vector3(-u_w * 0.3 + c * 0.06, y, back_z)
		connector.material = _mat_steel
		add_child(connector)

	# ── Câbles arrière ──
	var cable := CSGBox3D.new()
	cable.size     = Vector3(0.015, 0.015, rack_size.z * 0.3)
	cable.position = Vector3(-u_w * 0.15, y, -rack_size.z * 0.2)
	cable.material = _mat_cable
	add_child(cable)


# ──────────────────────────────────────────────
#  GOUTTIÈRE À CÂBLES (bas du rack, arrière)
# ──────────────────────────────────────────────

func _build_cable_tray() -> void:
	var tray_y := -rack_size.y * 0.5 + wall_thickness + 0.04

	# Fond de la gouttière
	var tray := CSGBox3D.new()
	tray.size     = Vector3(rack_size.x - wall_thickness * 2, 0.025, 0.18)
	tray.position = Vector3(0.0, tray_y, -rack_size.z * 0.5 + 0.09 + wall_thickness)
	tray.material = _mat_steel
	add_child(tray)

	# Câbles en vrac (gros bundle)
	var bundle := CSGBox3D.new()
	bundle.size     = Vector3(rack_size.x * 0.6, 0.06, 0.16)
	bundle.position = Vector3(0.0, tray_y + 0.04, -rack_size.z * 0.5 + 0.09 + wall_thickness)
	bundle.material = _mat_cable
	add_child(bundle)

	# Colliers de serrage simulés
	for i in 3:
		var clamp_node := CSGBox3D.new()
		clamp_node.size     = Vector3(rack_size.x * 0.62, 0.008, 0.008)
		clamp_node.position = Vector3(0.0, tray_y + 0.07, -rack_size.z * 0.5 + 0.04 + i * 0.06 + wall_thickness)
		clamp_node.material = _mat_steel
		add_child(clamp_node)


# ──────────────────────────────────────────────
#  PIEDS (4 coins)
# ──────────────────────────────────────────────

func _build_feet() -> void:
	var foot_h  := 0.08
	var offset_x := rack_size.x * 0.5 - 0.06
	var offset_z := rack_size.z * 0.5 - 0.06
	var base_y  := -rack_size.y * 0.5 - foot_h * 0.5

	for fx in [-1, 1]:
		for fz in [-1, 1]:
			var foot := CSGBox3D.new()
			foot.size     = Vector3(0.08, foot_h, 0.08)
			foot.position = Vector3(fx * offset_x, base_y, fz * offset_z)
			foot.material = _mat_steel
			add_child(foot)

			# Roulette (sphère simulée)
			var wheel := CSGSphere3D.new()
			wheel.radius   = 0.03
			wheel.position = Vector3(fx * offset_x, base_y - foot_h * 0.5, fz * offset_z)
			wheel.material = _mat_dark
			add_child(wheel)


# ──────────────────────────────────────────────
#  GRILLE DE VENTILATION HAUT
# ──────────────────────────────────────────────

func _build_top_fan_grille() -> void:
	var top_y := rack_size.y * 0.5

	# Panneau du dessus
	var top_panel := CSGBox3D.new()
	top_panel.size     = Vector3(rack_size.x, wall_thickness * 1.5, rack_size.z)
	top_panel.position = Vector3(0.0, top_y + wall_thickness * 0.75, 0.0)
	top_panel.material = _mat_rack
	add_child(top_panel)

	# Grille : rangée de trous ronds (simulés avec des CSGCylinder en soustraction)
	for col in 4:
		for row in 3:
			var hole := CSGCylinder3D.new()
			hole.operation = CSGShape3D.OPERATION_SUBTRACTION
			hole.radius    = 0.04
			hole.height    = wall_thickness * 4
			hole.position  = Vector3(
				-rack_size.x * 0.3 + col * (rack_size.x * 0.2),
				top_y + wall_thickness * 0.75,
				-rack_size.z * 0.25 + row * (rack_size.z * 0.25)
			)
			# Rotation pour que le cylindre perce verticalement
			hole.rotation_degrees = Vector3(0.0, 0.0, 0.0)
			add_child(hole)
