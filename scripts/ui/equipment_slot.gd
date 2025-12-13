extends InventorySlotUI
class_name EquipmentSlotUI

@export var equip_slot_name: String = "MainHand"
@export var accepted_type: ItemData.ItemType = ItemData.ItemType.WEAPON

# Placeholder icon when empty
@export var placeholder_texture: Texture2D

func _ready() -> void:
	super._ready() # Connects signals
	
	# Set placeholder if empty
	if not current_slot_data or not current_slot_data.item_data:
		icon_rect.texture = placeholder_texture
		icon_rect.visible = placeholder_texture != null
		quantity_label.visible = false

# Override drop data to enforce type restriction
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# Use basic dictionary check first
	if not (typeof(data) == TYPE_DICTIONARY and data.has("index")):
		return false
		
	# We need to know WHAT item is being dragged. 
	# The dragged data only has "index".
	# We need access to the source inventory to check the item type.
	# This requires the UI to facilitate, OR we pass item data in the drag payload.
	# Let's check if the payload has item_data (we might need to modify InventorySlot to add it).
	
	if data.has("item_type"):
		return data["item_type"] == accepted_type
		
	return false

# Override drop to handle equip logic
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	# Emit a special signal for equipping
	# We can reuse request_swap but use a special index or handled by parent
	# A cleaner way: emit 'request_equip(inventory_index, equip_slot_name)'
	if get_parent().has_method("_on_request_equip"):
		get_parent()._on_request_equip(data["index"], equip_slot_name)
