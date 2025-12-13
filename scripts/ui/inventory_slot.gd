extends PanelContainer
class_name InventorySlotUI

# ------------------------------------------------------------------------------
# Inventory Slot UI
# ------------------------------------------------------------------------------
# Visualizes a single slot in the inventory grid.
# ------------------------------------------------------------------------------

signal slot_clicked(index: int)

@onready var icon_rect: TextureRect = $MarginContainer/Icon
@onready var quantity_label: Label = $QuantityLabel

var slot_index: int = -1

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			slot_clicked.emit(slot_index)

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
