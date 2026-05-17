@tool
extends CSGCombiner3D
class_name Instantiate

@export var material : BaseMaterial3D
@export_tool_button("New Server", "ServerRack") var action1 = new_Server
@export_tool_button("Delete All", "Remove") var action4 = delete_all
@export_tool_button("Delete Last", "Remove") var action5 = delete_last
@export_tool_button("Delete First", "Remove") var action6 = delete_first
## Deletes all children.
func delete_all():
	for child in get_children():
		child.free()
	x = 0
	
	
var x := 0

## Instantiates a CSG box.
func new_Server():
	var node = ServerRack.new()
	node.name = "Server"
	node.material = material
	add_child(node, true)
	node.position.x = x
	x += 1
	node.owner = get_tree().edited_scene_root
	
func delete_last():
	if get_child_count():
		get_child(-1).free()
		x -= 1
		
## Deletes the last child.
func delete_first():
	if get_child_count():
		get_child(0).free()
		x -= 1
