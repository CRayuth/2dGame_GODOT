extends CanvasLayer
class_name InventoryUI

# ------------------------------------------------------------------------------
# Inventory UI Manager
# ------------------------------------------------------------------------------
# Manages the full inventory interface (Grid + Details Panel).
# ------------------------------------------------------------------------------

@onready var grid_container: GridContainer = $ColorRect/HBoxContainer/GridContainer
@onready var details_panel: Panel = $ColorRect/HBoxContainer/DetailsPanel

# Details UI References
@onready var detail_name: Label = $ColorRect/HBoxContainer/DetailsPanel/MarginContainer/VBoxContainer/NameLabel
@onready var detail_desc: Label = $ColorRect/HBoxContainer/DetailsPanel/MarginContainer/VBoxContainer/DescLabel
@onready var detail_icon: TextureRect = $ColorRect/HBoxContainer/DetailsPanel/MarginContainer/VBoxContainer/IconRect

var inventory_data: InventoryData
var slot_scene = preload("res://scenes/ui/inventory_slot.tscn")

func _ready() -> void:
	# Hide by default
	visible = false

	# For testing: specific manual assignment
	# In a real game, this might be injected or exist on the player
	inventory_data = InventoryData.new(16)
	inventory_data.inventory_updated.connect(update_slot)
	
	_init_grid()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"): # We need to add this action
		toggle_visibility()

func toggle_visibility() -> void:
	visible = not visible
	if visible:
		# Update all slots to be safe
		for i in range(inventory_data.slots.size()):
			update_slot(i)

func _init_grid() -> void:
	# Clear existing children if any
	for child in grid_container.get_children():
		child.queue_free()
	
	# Create slots
	for i in range(inventory_data.max_slots):
		var slot = slot_scene.instantiate()
		slot.slot_index = i
		slot.slot_clicked.connect(_on_slot_clicked)
		grid_container.add_child(slot)

# --- Update Logic ---

func update_slot(index: int) -> void:
	var slot_ui: InventorySlotUI = grid_container.get_child(index)
	var slot_data = inventory_data.slots[index]
	slot_ui.set_slot_data(slot_data)

func _on_slot_clicked(index: int) -> void:
	var slot_data = inventory_data.slots[index]
	if slot_data and slot_data.item_data:
		_show_details(slot_data.item_data)
	else:
		_clear_details()

func _show_details(item: ItemData) -> void:
	detail_name.text = item.name
	detail_desc.text = item.description
	detail_icon.texture = item.icon
	detail_icon.visible = true

func _clear_details() -> void:
	detail_name.text = "Select an Item"
	detail_desc.text = ""
	detail_icon.visible = false
