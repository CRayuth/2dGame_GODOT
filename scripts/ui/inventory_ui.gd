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
# Stat References (Right Page)
@onready var stats_list: VBoxContainer = $BookPanel/PagesContainer/RightPage/StatsList
@onready var hero_name_label: Label = $BookPanel/PagesContainer/RightPage/Header/NameLabel
@onready var book_panel: Panel = $BookPanel

# Equipment References L
@onready var head_slot_ui: EquipmentSlotUI = $BookPanel/PagesContainer/LeftPage/CharacterSection/EquipmentLayout/EquipSlots/HeadSlot
@onready var body_slot_ui: EquipmentSlotUI = $BookPanel/PagesContainer/LeftPage/CharacterSection/EquipmentLayout/EquipSlots/BodySlot
@onready var main_hand_slot_ui: EquipmentSlotUI = $BookPanel/PagesContainer/LeftPage/CharacterSection/EquipmentLayout/EquipSlots/MainHandSlot

# Equipment References R
@onready var legs_slot_ui: EquipmentSlotUI = $BookPanel/PagesContainer/LeftPage/CharacterSection/EquipmentLayout/EquipSlotsRight/LegsSlot
@onready var feet_slot_ui: EquipmentSlotUI = $BookPanel/PagesContainer/LeftPage/CharacterSection/EquipmentLayout/EquipSlotsRight/FeetSlot
@onready var off_hand_slot_ui: EquipmentSlotUI = $BookPanel/PagesContainer/LeftPage/CharacterSection/EquipmentLayout/EquipSlotsRight/OffHandSlot

var inventory_data: InventoryData
var equipment_data: EquipmentData

var slot_scene = preload("res://scenes/ui/inventory_slot.tscn")
var tooltip_scene = preload("res://scenes/ui/tooltip.tscn")
var tooltip_instance: Tooltip

# Stat Labels
var stat_labels: Dictionary = {}

func _ready() -> void:
	# Hide by default
	visible = false
	book_panel.modulate.a = 0
	
	# Instantiate Tooltip
	tooltip_instance = tooltip_scene.instantiate()
	add_child(tooltip_instance)

	# Initialize Data
	inventory_data = InventoryData.new(16)
	inventory_data.inventory_updated.connect(update_slot)
	
	equipment_data = EquipmentData.new()
	equipment_data.equipment_updated.connect(update_equipment_slots)
	
	# Cache stat labels
	_cache_stat_labels()
	
	_init_grid()
	_init_equipment_slots()
	_update_character_info()
	_update_stats()

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
	if visible: animate_close()
	else: animate_open()

func _init_grid() -> void:
	for child in grid_container.get_children():
		child.queue_free()
	
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

func _init_equipment_slots() -> void:
	# Connect signals for existing equipment slots
	var slots = [head_slot_ui, body_slot_ui, main_hand_slot_ui, legs_slot_ui, feet_slot_ui, off_hand_slot_ui]
	for slot in slots:
		slot.request_tooltip.connect(_on_show_tooltip)
		slot.hide_tooltip.connect(_on_hide_tooltip)

# --- Update Logic ---

func _on_slot_request_swap(source_index: int, target_index: int) -> void:
	inventory_data.swap_slots(source_index, target_index)

func _on_request_equip(inventory_index: int, equip_slot_name: String) -> void:
	# Logic:
	# 1. Get item from inventory
	var slot_data = inventory_data.slots[inventory_index]
	var item_to_equip = slot_data.item_data
	
	if not item_to_equip: return
	
	# 2. Call equipment_data.equip_item -> returns old item
	var returned_item = equipment_data.equip_item(item_to_equip, equip_slot_name)
	
	# 3. Handle old item (put back in inventory or swap)
	slot_data.item_data = returned_item
	if returned_item:
		slot_data.quantity = 1
	else:
		slot_data.quantity = 0
		
	inventory_data.inventory_updated.emit(inventory_index)
	
	# 4. Trigger Stat Update
	_update_stats()

func update_slot(index: int) -> void:
	if not grid_container: return
	if index < grid_container.get_child_count():
		var slot_ui: InventorySlotUI = grid_container.get_child(index)
		var slot_data = inventory_data.slots[index]
		slot_ui.set_slot_data(slot_data)

func update_equipment_slots(slot_name: String) -> void:
	match slot_name:
		"Head": head_slot_ui.set_slot_data(equipment_data.head_slot)
		"Body": body_slot_ui.set_slot_data(equipment_data.body_slot)
		"MainHand": main_hand_slot_ui.set_slot_data(equipment_data.main_hand_slot)
		"Legs": legs_slot_ui.set_slot_data(equipment_data.legs_slot)
		"Feet": feet_slot_ui.set_slot_data(equipment_data.feet_slot)
		"OffHand": off_hand_slot_ui.set_slot_data(equipment_data.off_hand_slot)

func _on_slot_clicked(index: int) -> void:
	var slot_data = inventory_data.slots[index]
	if slot_data and slot_data.item_data:
		print("Clicked item: ", slot_data.item_data.name)

func _update_character_info() -> void:
	if hero_name_label:
		var char_type = GameManager.get_selected_character()
		hero_name_label.text = "Hero" 

func _cache_stat_labels() -> void:
	# Find labels in the VBox
	var str_row = stats_list.get_node_or_null("StatRow_Str")
	if str_row: stat_labels["Strength"] = str_row.get_node("Value")
	
	var agi_row = stats_list.get_node_or_null("StatRow_Agi")
	if agi_row: stat_labels["Agility"] = agi_row.get_node("Value")

func _update_stats() -> void:
	# Base Stats
	var strength = 10
	var agility = 8
	
	# Add Bonuses
	if equipment_data.main_hand_slot.item_data:
		strength += equipment_data.main_hand_slot.item_data.attack_bonus
	
	if equipment_data.body_slot.item_data:
		agility += equipment_data.body_slot.item_data.defense_bonus
	
	if equipment_data.legs_slot.item_data:
		agility += equipment_data.legs_slot.item_data.defense_bonus
		
	if equipment_data.feet_slot.item_data:
		agility += equipment_data.feet_slot.item_data.defense_bonus # Boots usually give speed/agi
	
	if equipment_data.off_hand_slot.item_data:
		strength += equipment_data.off_hand_slot.item_data.defense_bonus # Shield
		
	# Update UI
	if stat_labels.has("Strength"): stat_labels["Strength"].text = str(strength)
	if stat_labels.has("Agility"): stat_labels["Agility"].text = str(agility)

func _on_show_tooltip(slot_data: SlotData) -> void:
	if slot_data and slot_data.item_data:
		tooltip_instance.display(slot_data.item_data)

func _on_hide_tooltip() -> void:
	tooltip_instance.hide()
