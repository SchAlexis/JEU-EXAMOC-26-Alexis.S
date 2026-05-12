@tool

extends Label3D


## Button action to update the text.

@export_tool_button("Update") var action := create


# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	create()


## Sets the `Label3D` text attribute to the parent's name.

func create():

	var parent = get_parent()

	text = parent.name
