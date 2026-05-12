@tool
extends CSGCombiner3D
class_name InstantiateMatrix


@export var material : BaseMaterial3D
@export_tool_button("New Matrix", "CSGBox3D") var action1 = new_matrix
@export var repeat = Vector3i(2, 2, 2)
@export var step = Vector3(2, 2, 2)

@export_tool_button("Delete All", "Remove") var action4 = delete_all




func delete_all():
	for child in get_children():
		child.free()

	
	


## Instantiates a CSG box.
func new_matrix():
	for x in repeat.x:
		for y in repeat.y:
			for z in repeat.z:
				var node = CSGBox3D.new()
				node.name = "Box"
				node.material = material
				add_child(node, true)
				node.position.x = x * 2
				node.position.y = y * 2
				node.position.z = z * 2
				node.owner = get_tree().edited_scene_root
	
