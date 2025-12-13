extends Resource
class_name EquipmentData

signal equipment_updated(slot_name: String)

@export var head_slot: SlotData
@export var body_slot: SlotData
@export var main_hand_slot: SlotData
@export var legs_slot: SlotData
@export var feet_slot: SlotData
@export var off_hand_slot: SlotData

func _init() -> void:
	# Initialize empty slots
	head_slot = SlotData.new()
	body_slot = SlotData.new()
	main_hand_slot = SlotData.new()
	legs_slot = SlotData.new()
	feet_slot = SlotData.new()
	off_hand_slot = SlotData.new()

func equip_item(item: ItemData, slot_name: String) -> ItemData:
	# Returns the previously equipped item (if any), or null
	var target_slot: SlotData
	
	match slot_name:
		"Head": target_slot = head_slot
		"Body": target_slot = body_slot
		"MainHand": target_slot = main_hand_slot
		"Legs": target_slot = legs_slot
		"Feet": target_slot = feet_slot
		"OffHand": target_slot = off_hand_slot
		_: return item # Return item back if invalid slot
		
	var previous_item = target_slot.item_data
	target_slot.item_data = item
	target_slot.quantity = 1 # Equipment is always 1
	
	equipment_updated.emit(slot_name)
	return previous_item

func unequip_item(slot_name: String) -> ItemData:
	var target_slot: SlotData
	match slot_name:
		"Head": target_slot = head_slot
		"Body": target_slot = body_slot
		"MainHand": target_slot = main_hand_slot
		"Legs": target_slot = legs_slot
		"Feet": target_slot = feet_slot
		"OffHand": target_slot = off_hand_slot
		_: return null
		
	var item = target_slot.item_data
	target_slot.item_data = null
	target_slot.quantity = 0
	
	equipment_updated.emit(slot_name)
	return item
