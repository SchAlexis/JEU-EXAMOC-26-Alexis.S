@tool
extends CSGBox3D
class_name HollowBox
## Creates a hollow box.

@export var thickness := 0.1:  ## Wall thickness.
	set(value):
		thickness = value
		create()

## Button action to rebuild the node.
@export_tool_button("Rebuild") var action = create

func _ready():
	create()

## Subtracts an inner box to create a hollow box.
func create():
	var inner = null
	# find a procedurally created node
	for child in get_children():
		if child.owner == null:
			inner = child
			break
			
	# create one if it does not exist
	if inner == null:
		inner = CSGBox3D.new()
		inner.operation = CSGShape3D.OPERATION_SUBTRACTION
		add_child(inner)
		
	# update it
	if material:
		inner.material = material
	inner.size = size
	inner.size.x -= thickness * 2
	inner.size.y -= thickness * 2
	inner.size.z += 0.01 # Slightly taller to avoid "Z-fighting" or thin faces
