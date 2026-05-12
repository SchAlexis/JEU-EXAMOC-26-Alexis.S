extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_down() -> void:
	print("button down") 

func _on_button_up() -> void:
	print("button up") 


func _on_pressed() -> void:
	print("button pressed") 


func _on_color_picker_button_color_changed(color: Color) -> void:
	print("color changed: ", color)


func _on_option_button_item_selected(index: int) -> void:
	print("item selected: ", index)
