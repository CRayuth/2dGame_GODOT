extends CanvasLayer
class_name ChestUI

# ------------------------------------------------------------------------------
# Chest UI Manager
# ------------------------------------------------------------------------------
# Manages the dual-inventory display:
# - Top Panel: Chest Inventory
# - Bottom Panel: Player Inventory
# Handles clicking to transfer items between them.
# ------------------------------------------------------------------------------

@onready var chest_grid: GridContainer = $Panel/ChestScroll/ChestGrid
@onready var player_grid: GridContainer = $Panel/PlayerScroll/PlayerGrid
@onready var close_button: Button = $Panel/Header/CloseButton

# Data References
var current_chest: Chest
var player_inventory: InventoryData

# Scene Resources
var slot_scene = preload("res://scenes/ui/inventory_slot.tscn")

func _ready() -> void:
	# Hidden by default
	visible = false
	if close_button:
		close_button.pressed.connect(close)

# Open the UI with specific data
func open(chest: Chest, p_inventory: InventoryData) -> void:
	current_chest = chest
	player_inventory = p_inventory
	
	# Connect signals to update UI when data changes
	if not current_chest.inventory_data.inventory_updated.is_connected(_on_chest_updated):
		current_chest.inventory_data.inventory_updated.connect(_on_chest_updated)
	
	# Only connect player inventory once (globally or check connection)
	if not player_inventory.inventory_updated.is_connected(_on_player_updated):
		player_inventory.inventory_updated.connect(_on_player_updated)
	
	_refresh_all()
	visible = true
	
	# Pause game? Usually inventory pauses or at least blocks input
	# get_tree().paused = true 

func close() -> void:
	visible = false
	current_chest = null
	# get_tree().paused = false

func _refresh_all() -> void:
	_init_grid(chest_grid, current_chest.inventory_data, true)
	_init_grid(player_grid, player_inventory, false)

func _init_grid(grid: GridContainer, data: InventoryData, is_chest: bool) -> void:
	# Clear existing
	for child in grid.get_children():
		child.queue_free()
		
	# Create slots
	for i in range(data.slots.size()):
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		
		# Setup Slot
		if slot.has_method("set_slot_data"):
			slot.set_slot_data(data.slots[i])
			
		# Connect Click Signal
		# We assume InventorySlot has a signal 'slot_clicked(index)'
		# We need to bind context (which inventory is it?)
		slot.slot_clicked.connect(_on_slot_clicked.bind(i, is_chest))

# Handle clicks to transfer items
func _on_slot_clicked(index: int, is_from_chest: bool) -> void:
	if is_from_chest:
		_transfer_item(index, current_chest.inventory_data, player_inventory)
	else:
		_transfer_item(index, player_inventory, current_chest.inventory_data)

func _transfer_item(index: int, from_inv: InventoryData, to_inv: InventoryData) -> void:
	var slot_data = from_inv.slots[index]
	if not slot_data.item_data:
		return
	
	# Try to add to target inventory
	var success = to_inv.add_item(slot_data.item_data, slot_data.quantity)
	
	if success:
		# Remove from source
		slot_data.item_data = null
		slot_data.quantity = 0
		from_inv.inventory_updated.emit(index)

func _on_chest_updated(_index: int) -> void:
	if current_chest and visible:
		_init_grid(chest_grid, current_chest.inventory_data, true)

func _on_player_updated(_index: int) -> void:
	if player_inventory and visible:
		_init_grid(player_grid, player_inventory, false)
