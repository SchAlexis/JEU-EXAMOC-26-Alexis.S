extends Node3D

@export_tool_button("Create", "CSGBox3D") var action1 = create
@onready var labbel : Label = $Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Label.text)
	print('.....')
func create():
	for child in get_children():
		child.free()
	var mots = label.text.split(' ')

	for mot in mots:
		var node = Label3D.new()
		node.name = "label"
		node.text = mot
		add_child(node, true)
		node.position = Vector3(randfn(0, 3), 0,randfn(0, 3))
		node.owner = get_tree().edited_scene_root
