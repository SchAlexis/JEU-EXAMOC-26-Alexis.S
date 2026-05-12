@tool
extends CSGCylinder3D
class_name HollowTube
## Creates a hollow tube.

@export var thickness := 0.1:  ## Wall thicknness.
	set(value):
		thickness = value
		create()

## Button action to rebuild the hollow tube.
@export_tool_button("Rebuild") var action := create


func _ready():
	create()

## Subtracts an inner cylinder from the `CSGCylidner3D`.
func create():
	var inner = null
	# find a procedurally created node
	for child in get_children():
		if child.owner == null:
			inner = child
			break
			
	# create one if it does not exist
	if inner == null:
		inner = CSGCylinder3D.new()
		inner.operation = CSGShape3D.OPERATION_SUBTRACTION
		add_child(inner)
		
			# update it
	if material:
		inner.material = material
	inner.radius = radius - thickness
	inner.height = height * 1.01 # Slightly taller to avoid "Z-fighting" or thin faces
	inner.sides = sides
	inner.cone = cone
