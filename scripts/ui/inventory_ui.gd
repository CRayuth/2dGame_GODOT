extends CanvasLayer
class_name InventoryUI

# ------------------------------------------------------------------------------
# Inventory UI Manager
# ------------------------------------------------------------------------------
# Manages the full inventory interface (Book Layout).
# ------------------------------------------------------------------------------

# New References for Book Layout
@onready var grid_container: GridContainer = $BookPanel/PagesContainer/LeftPage/InventoryGrid

# Stat References (Right Page) - specific nodes can be accessed via unique names or indices later
@onready var stats_list: VBoxContainer = $BookPanel/PagesContainer/RightPage/StatsList
@onready var hero_name_label: Label = $BookPanel/PagesContainer/RightPage/Header/NameLabel

var inventory_data: InventoryData
var slot_scene = preload("res://scenes/ui/inventory_slot.tscn")

func _ready() -> void:
	# Hide by default
	visible = false

	# For testing: specific manual assignment
	inventory_data = InventoryData.new(16)
	inventory_data.inventory_updated.connect(update_slot)
	
	_init_grid()
	_update_character_info()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"): 
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
		slot.request_swap.connect(_on_slot_request_swap)
		grid_container.add_child(slot)

# --- Update Logic ---

func _on_slot_request_swap(source_index: int, target_index: int) -> void:
	inventory_data.swap_slots(source_index, target_index)

func update_slot(index: int) -> void:
	# Safety check for path
	if not grid_container: return
	
	if index < grid_container.get_child_count():
		var slot_ui: InventorySlotUI = grid_container.get_child(index)
		var slot_data = inventory_data.slots[index]
		slot_ui.set_slot_data(slot_data)

func _on_slot_clicked(index: int) -> void:
	var slot_data = inventory_data.slots[index]
	if slot_data and slot_data.item_data:
		print("Clicked item: ", slot_data.item_data.name)
		# TODO: Show item details popup or tooltip
	else:
		print("Clicked empty slot: ", index)

func _update_character_info() -> void:
	# OOP: Fetch data from GameManager (Global State)
	if hero_name_label:
		# Simple logic to get name, ideally this comes from a PlayerStats resource
		var char_type = GameManager.get_selected_character()
		if char_type == GameManager.CharacterType.WARRIOR:
			hero_name_label.text = "Warrior"
		elif char_type == GameManager.CharacterType.BOWMAN:
			hero_name_label.text = "Bowman"
		else:
			hero_name_label.text = "Unknown Hero"
