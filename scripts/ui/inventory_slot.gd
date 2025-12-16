extends PanelContainer
class_name InventorySlotUI

# ------------------------------------------------------------------------------
# Inventory Slot UI
# ------------------------------------------------------------------------------
# Visualizes a single slot in the inventory grid.
# ------------------------------------------------------------------------------

signal slot_clicked(index: int)
signal request_swap(source_index: int, target_index: int)
signal request_tooltip(slot_data: SlotData)
signal hide_tooltip

@onready var icon_rect: TextureRect = $MarginContainer/Icon
@onready var quantity_label: Label = $QuantityLabel

var slot_index: int = -1

func _ready() -> void:
	# OOP: Encapsulate hover behavior within the slot
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

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
	if current_slot_data and current_slot_data.item_data:
		data["item_type"] = current_slot_data.item_data.item_type
	
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

var current_slot_data: SlotData = null

func _on_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE)
	
	if current_slot_data and current_slot_data.item_data:
		request_tooltip.emit(current_slot_data)

func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	hide_tooltip.emit()

func set_slot_data(slot_data: SlotData) -> void:
	current_slot_data = slot_data
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
