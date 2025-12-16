class_name Chest
extends Interactable

# ------------------------------------------------------------------------------
# Chest Class (OOP: Polymorphism)
# ------------------------------------------------------------------------------
# Represents a container in the world.
# Holds its own InventoryData and emits a signal when opened.
# ------------------------------------------------------------------------------

signal chest_opened(chest: Chest)

@export var inventory_data: InventoryData

func _ready() -> void:
	# Initialize with some default slots (e.g., 20)
	if not inventory_data:
		inventory_data = InventoryData.new(20)
	
	z_index = 10 # Ensure it's rendered above the floor
	print("Chest instantiated at: ", position)
		
	# DEBUG: Add a test item
	var test_item = ItemData.new()
	test_item.name = "Test Anvil"
	test_item.icon = load("res://assets/pixel2d/Environment/Structures/Stations/Anvil/Anvil.png")
	test_item.description = "A heavy anvil."
	inventory_data.add_item(test_item, 5)
	
	var wood_item = ItemData.new()
	wood_item.name = "Wood"
	# Placeholder icon if needed, or re-use existing
	wood_item.icon = load("res://assets/pixel2d/Environment/Structures/Stations/Anvil/Anvil.png") 
	inventory_data.add_item(wood_item, 10)

# Override the base interact method
func interact(_player: Player) -> void:
	print("Interacting with Chest!")
	chest_opened.emit(self)
