extends Control


func _on_new_button_down() -> void:
	$TextEdit.text = ""

func _on_load_button_down() -> void:
	$FileDialog.visible = true
	
func _on_save_button_down() -> void:
	$SaveDialog.visible = true
	
func _on_file_dialog_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	$TextEdit.text = content
	
func _on_save_dialog_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string($TextEdit.text)


func _on_open_file_files_selected(paths: PackedStringArray) -> void:
	pass # Replace with function body.
