extends Resource
class_name ItemData

# ------------------------------------------------------------------------------
# Item Data Resource
# ------------------------------------------------------------------------------
# Defines the static properties of an item.
# This follows the Flyweight pattern: shared data is stored here, 
# while unique instance data (like quantity or durability) is stored in the InventorySlot.
# ------------------------------------------------------------------------------

@export var name: String = "Item Name"
@export_multiline var description: String = "Item Description"
@export var stackable: bool = true
@export var max_stack: int = 99
@export var icon: Texture2D
@export var rarity: GameManager.ItemRarity = GameManager.ItemRarity.COMMON

enum ItemType {
	WEAPON,
	HEAD,
	BODY,
	LEGS,
	FEET,
	OFF_HAND,
	CONSUMABLE,
	OTHER
}
@export var item_type: ItemType = ItemType.OTHER

# Optional: Add stats for equipment
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
