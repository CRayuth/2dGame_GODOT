extends Node2D

# ------------------------------------------------------------------------------
# Gameplay Scene Manager
# ------------------------------------------------------------------------------
# Handles level initialization, prop placement, and player spawning.
# ------------------------------------------------------------------------------

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var spawn_point: Marker2D = $SpawnPoint

# Preload scenes
var player_scene = preload("res://scenes/player.tscn")
var game_ui_scene = preload("res://scenes/game_ui.tscn")

var game_ui_instance = null
var inventory_ui_scene = preload("res://scenes/ui/inventory_ui.tscn")
var inventory_ui_instance = null

var chest_scene = preload("res://scenes/chest.tscn")
var chest_ui_scene = preload("res://scenes/ui/chest_ui.tscn")
var chest_ui_instance = null

func _ready() -> void:
	print("Gameplay Scene Started")
	
	# 1. Generate Floor
	_generate_floor()
	
	# 2. Find or Create UI
	# We check if it exists in case we add it manually to the scene later
	if has_node("GameUI"):
		game_ui_instance = $GameUI
	else:
		game_ui_instance = game_ui_scene.instantiate()
		add_child(game_ui_instance)
	
	# 3. Add Inventory UI (Add before Player so Player gets input priority)
	inventory_ui_instance = inventory_ui_scene.instantiate()
	add_child(inventory_ui_instance)
	
	# 4. Spawn Player (Last added handles input first)
	_spawn_player()
	
	# 5. Input Map Setup for Inventory
	if not InputMap.has_action("toggle_inventory"):
		InputMap.add_action("toggle_inventory")
		var ev = InputEventKey.new()
		ev.physical_keycode = KEY_E
		InputMap.action_add_event("toggle_inventory", ev)
	
	# 6. Interact Input
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		var ev = InputEventKey.new()
		ev.physical_keycode = KEY_E
		InputMap.action_add_event("interact", ev)
		
	# 7. Spawn Test Chest
	var chest = chest_scene.instantiate()
	chest.position = Vector2(650, 324) # Near player spawn
	add_child(chest)
	# Connect signal
	if chest.has_signal("chest_opened"):
		chest.chest_opened.connect(_on_chest_opened)
		
	# 8. Add Chest UI
	chest_ui_instance = chest_ui_scene.instantiate()
	add_child(chest_ui_instance)
	


func _generate_floor() -> void:
	if not tile_map:
		return
		
	# Fill a 20x20 area with floor tiles (Source ID 0, Atlas Coords 0,0)
	# This ensures the player has something to walk on and see
	for x in range(-10, 20):
		for y in range(-10, 20):
			tile_map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

func _spawn_player() -> void:
	if not player_scene:
		push_error("Player scene not assigned!")
		return
		
	# Create a new instance of the player
	var player_instance = player_scene.instantiate()
	
	# Set position to the SpawnPoint marker
	if spawn_point:
		player_instance.position = spawn_point.position
	else:
		# Fallback center position
		player_instance.position = Vector2(600, 300)
	
	# Add player to the scene tree
	add_child(player_instance)
	print("Player spawned at: ", player_instance.position)
	
	# --- OOP: Connect Signals (Observer Pattern) ---
	# Connect Player (Model) -> UI (View)
	if game_ui_instance and player_instance.has_method("_get_input_vector"): # Check if valid player
		# We need to wait a frame for the player to initialize its data (in its _ready)
		# But since we are instantiating it, its _ready runs when added to child.
		# However, we can manually setup the UI with initial values if we access the player's data.
		# Since player loads data in _ready, we can trust it will have values soon.
		
		# Connect Signals
		player_instance.health_changed.connect(game_ui_instance.update_health)
		player_instance.stamina_changed.connect(game_ui_instance.update_stamina)
		
		# Initial Setup of UI
		# We cast to Player to access specific properties safely
		var p = player_instance
		if "max_hp" in p and "max_stamina" in p:
			# Get character name from GameManager
			var char_name = "Character"
			if GameManager.selected_character == GameManager.CharacterType.WARRIOR:
				char_name = "Warrior"
			elif GameManager.selected_character == GameManager.CharacterType.BOWMAN:
				char_name = "Bowman"
				
			game_ui_instance.setup(char_name, p.max_hp, p.max_stamina)

func _process(_delta: float) -> void:
	# Check for exit (Escape key) to return to menu
	if Input.is_action_just_pressed("ui_cancel"):
		_return_to_menu()

func _return_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_chest_opened(chest: Chest) -> void:
	if chest_ui_instance and inventory_ui_instance:
		# Use the player's inventory data from the existing UI
		chest_ui_instance.open(chest, inventory_ui_instance.inventory_data)
		
		# DEBUG: Ensure player has items to show
		if inventory_ui_instance.inventory_data.slots[0].item_data == null:
			var item = ItemData.new()
			item.name = "Player Sword"
			item.icon = load("res://assets/pixel2d/Environment/Structures/Stations/Anvil/Anvil.png")
			inventory_ui_instance.inventory_data.add_item(item, 1)
