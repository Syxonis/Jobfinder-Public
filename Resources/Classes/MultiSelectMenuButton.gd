extends MenuButton
class_name MultiSelectMenuButton

@export var default_text: String = "Select..."  # Text always shown on button

func _ready() -> void:
	text = default_text
	var popup := get_popup()
	popup.hide_on_checkable_item_selection = false
	popup.id_pressed.connect(_on_item_pressed)


func set_items(items: Array) -> void:
	var popup := get_popup()
	popup.clear()
	for item in items:
		popup.add_check_item(item)


func _on_item_pressed(id: int) -> void:
	var popup := get_popup()
	var checked := popup.is_item_checked(id)
	popup.set_item_checked(id, !checked)  # toggle
	Global.angebotFilterUpdate.emit()


func get_selected_items() -> Array[String]:
	var popup := get_popup()
	var selected: Array[String] = []
	for i in range(popup.item_count):
		if popup.is_item_checked(i):
			selected.append(popup.get_item_text(i))
	return selected
