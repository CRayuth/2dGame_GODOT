extends Resource
class_name InventoryData

# ------------------------------------------------------------------------------
# Inventory Data
# ------------------------------------------------------------------------------
# Handles the logic for the inventory (adding, removing, stacking).
# It does NOT handle the UI. It emits signals when data changes.
# ------------------------------------------------------------------------------

signal inventory_updated(index: int)
signal item_added(item: ItemData, quantity: int)

@export var slots: Array[SlotData] = []
var max_slots: int = 20 # 4x5 grid

func _init(p_max_slots: int = 20) -> void:
	max_slots = p_max_slots
	slots.resize(max_slots)
	# Initialize empty slots
	for i in range(max_slots):
		slots[i] = SlotData.new()

# --- Public Methods ---

func add_item(item: ItemData, quantity: int = 1) -> bool:
	if item.stackable:
		# 1. Try to merge with existing stacks
		for i in range(slots.size()):
			if slots[i].item_data == item and slots[i].quantity < item.max_stack:
				var space = item.max_stack - slots[i].quantity
				var add_amount = min(quantity, space)
				
				slots[i].quantity += add_amount
				quantity -= add_amount
				inventory_updated.emit(i)
				
				if quantity == 0:
					return true
	
	# 2. Add to first empty slot
	for i in range(slots.size()):
		if slots[i].item_data == null:
			slots[i].item_data = item
			slots[i].quantity = quantity
			inventory_updated.emit(i)
			return true
			
	# Inventory full
	return false
