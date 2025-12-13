extends PanelContainer
class_name Tooltip

# ------------------------------------------------------------------------------
# Tooltip UI
# ------------------------------------------------------------------------------
# Displays item information. Managed by InventoryUI.
# ------------------------------------------------------------------------------

@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var desc_label: Label = $MarginContainer/VBoxContainer/DescLabel

func _ready() -> void:
	# Ensure it ignores mouse input so it doesn't block clicks
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()

func display(item: ItemData) -> void:
	name_label.text = item.name
	desc_label.text = item.description
	
	# Reset size to fit content
	size = Vector2.ZERO 
	show()

func update_position(mouse_pos: Vector2) -> void:
	# Offset slightly so it's not under the cursor
	global_position = mouse_pos + Vector2(15, 15)
