extends Node2D

# ------------------------------------------------------------------------------
# Gameplay Scene Manager
# ------------------------------------------------------------------------------
# Handles level initialization, prop placement, and player spawning.
# ------------------------------------------------------------------------------

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var spawn_point: Marker2D = $SpawnPoint

# Preload the player scene to instantiate it
var player_scene = preload("res://scenes/player.tscn")

func _ready() -> void:
	print("Gameplay Scene Started")
	
	# Spawn the player character
	_spawn_player()

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

func _process(_delta: float) -> void:
	# Check for exit (Escape key) to return to menu
	if Input.is_action_just_pressed("ui_cancel"):
		_return_to_menu()

func _return_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
