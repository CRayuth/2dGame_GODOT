extends CanvasLayer
class_name InventoryUI

# ------------------------------------------------------------------------------
# Inventory UI Manager
# ------------------------------------------------------------------------------
# Manages the full inventory interface (Book Layout) with Animations.
# ------------------------------------------------------------------------------

# New References for Book Layout
@onready var grid_container: GridContainer = $BookPanel/PagesContainer/LeftPage/InventoryGrid

# Stat References (Right Page)
@onready var stats_list: VBoxContainer = $BookPanel/PagesContainer/RightPage/StatsList
@onready var hero_name_label: Label = $BookPanel/PagesContainer/RightPage/Header/NameLabel
@onready var book_panel: Panel = $BookPanel

var inventory_data: InventoryData
var slot_scene = preload("res://scenes/ui/inventory_slot.tscn")
var tooltip_scene = preload("res://scenes/ui/tooltip.tscn")
var tooltip_instance: Tooltip

func _ready() -> void:
	# Hide by default (Logic hidden, we control visibility via modulation/scale now)
	visible = false
	book_panel.modulate.a = 0
	
	# Instantiate Tooltip
	tooltip_instance = tooltip_scene.instantiate()
	add_child(tooltip_instance)

	# For testing: specific manual assignment
	inventory_data = InventoryData.new(16)
	inventory_data.inventory_updated.connect(update_slot)
	
	_init_grid()
	_update_character_info()

func _process(_delta: float) -> void:
	if tooltip_instance and tooltip_instance.visible:
		tooltip_instance.update_position(book_panel.get_global_mouse_position())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"): 
		if visible and book_panel.modulate.a > 0.9: # Check if open
			animate_close()
		elif not visible or book_panel.modulate.a < 0.1: # Check if closed
			animate_open()

func animate_open() -> void:
	visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(book_panel, "modulate:a", 1.0, 0.3)
	tween.tween_property(book_panel, "scale", Vector2(1.0, 1.0), 0.3).from(Vector2(0.8, 0.8)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func animate_close() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(book_panel, "modulate:a", 0.0, 0.2)
	tween.tween_property(book_panel, "scale", Vector2(0.8, 0.8), 0.2)
	tween.chain().tween_callback(func(): visible = false)

func toggle_visibility() -> void:
	# Deprecated by animate_open/close but kept for potential external calls
	if visible: animate_close()
	else: animate_open()

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
		
		# Connect Tooltip Signals
		slot.request_tooltip.connect(_on_show_tooltip)
		slot.hide_tooltip.connect(_on_hide_tooltip)
		
		grid_container.add_child(slot)
		
		# Initialize immediately
		slot.set_slot_data(inventory_data.slots[i])

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

func _on_show_tooltip(slot_data: SlotData) -> void:
	if slot_data and slot_data.item_data:
		tooltip_instance.display(slot_data.item_data)

func _on_hide_tooltip() -> void:
	tooltip_instance.hide()
