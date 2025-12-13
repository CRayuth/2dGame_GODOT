extends PanelContainer
class_name InventorySlotUI

# ------------------------------------------------------------------------------
# Inventory Slot UI
# ------------------------------------------------------------------------------
# Visualizes a single slot in the inventory grid.
# ------------------------------------------------------------------------------

signal slot_clicked(index: int)
signal request_swap(source_index: int, target_index: int)

@onready var icon_rect: TextureRect = $MarginContainer/Icon
@onready var quantity_label: Label = $QuantityLabel

var slot_index: int = -1

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			slot_clicked.emit(slot_index)

# --- Drag and Drop ---

func _get_drag_data(_at_position: Vector2) -> Variant:
	# Only allow drag if we have an item texture visible
	if not icon_rect.visible:
		return null
		
	var data = { "index": slot_index }
	
	# Create Preview
	var preview = TextureRect.new()
	preview.texture = icon_rect.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.size = Vector2(48, 48)
	preview.modulate.a = 0.8
	
	var control = Control.new()
	control.add_child(preview)
	preview.position = -preview.size / 2 # Center preview on mouse
	
	set_drag_preview(control)
	
	return data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("index")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var source_index = data["index"]
	if source_index != slot_index:
		request_swap.emit(source_index, slot_index)

func set_slot_data(slot_data: SlotData) -> void:
	if slot_data and slot_data.item_data:
		icon_rect.texture = slot_data.item_data.icon
		icon_rect.visible = true
		
		if slot_data.quantity > 1:
			quantity_label.text = str(slot_data.quantity)
			quantity_label.visible = true
		else:
			quantity_label.visible = false
	else:
		icon_rect.visible = false
		quantity_label.visible = false
