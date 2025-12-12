class_name Player
extends CharacterBody

# ------------------------------------------------------------------------------
# Player Class
# ------------------------------------------------------------------------------
# Inherits from CharacterBody.
# Represents the user-controlled character.
# Implements specific input handling (WASD) and stat initialization.
# ------------------------------------------------------------------------------

# Reference to the Camera2D to ensure it follows the player
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	print("Player initialized.")
	
	# Load stats/sprites based on selection from GameManager
	_initialize_character_data()

# --- OOP: Overriding Base Method ---

func _physics_process(delta: float) -> void:
	# Check for Run input
	is_running = Input.is_physical_key_pressed(KEY_SHIFT)
	
	# Call parent physics logic
	super._physics_process(delta)

# we override the base class method to provide specific input logic for the Player
func _get_input_vector() -> Vector2:
	var input_vector = Vector2.ZERO
	
	# Specific WASD Input (ignoring default ui_ actions which map to arrows)
	if Input.is_physical_key_pressed(KEY_W):
		input_vector.y -= 1
	if Input.is_physical_key_pressed(KEY_S):
		input_vector.y += 1
	if Input.is_physical_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_physical_key_pressed(KEY_D):
		input_vector.x += 1
	
	return input_vector

# --- Custom Methods ---

# Sets up sprites and stats based on the chosen character
func _initialize_character_data() -> void:
	var type = GameManager.get_selected_character()
	var data = CharacterData.get_character_data(type)
	
	# Apply stats from data
	self.hp = data.hp
	self.movement_speed = data.speed * 16 # Adjusted scale (was 12) for faster walk
	
	print("Initialized Player as: ", data.character_name)
	
	# Load Sprites
	_load_sprites(type)

func _load_sprites(type: GameManager.CharacterType) -> void:
	if not sprite:
		push_error("Sprite node missing on Player!")
		return
		
	sprite.sprite_frames = SpriteFrames.new()
	
	var idle_path = ""
	var walk_path = ""
	
	# Determine paths based on character type
	if type == GameManager.CharacterType.WARRIOR:
		idle_path = "res://assets/pixel2d/Entities/Characters/Body_A/Animations/Idle_Base/Idle_Side-Sheet.png"
		walk_path = "res://assets/pixel2d/Entities/Characters/Body_A/Animations/Walk_Base/Walk_Side-Sheet.png"
	elif type == GameManager.CharacterType.BOWMAN:
		idle_path = "res://assets/pixel2d/Entities/Characters/Body_A/Animations/Idle_Base/Idle_Side-Sheet.png"
		walk_path = "res://assets/pixel2d/Entities/Characters/Body_A/Animations/Walk_Base/Walk_Side-Sheet.png"
	else:
		# Fallback to Warrior if NONE or unknown (safety)
		idle_path = "res://assets/pixel2d/Entities/Characters/Body_A/Animations/Idle_Base/Idle_Side-Sheet.png"
		walk_path = "res://assets/pixel2d/Entities/Characters/Body_A/Animations/Walk_Base/Walk_Side-Sheet.png"

	# Helper function to load texture and add frames
	_add_animation("idle", idle_path, 4)
	_add_animation("walk", walk_path, 6)
	
	sprite.play("idle")

func _add_animation(anim_name: String, path: String, frame_count: int) -> void:
	var texture = load(path)
	if texture:
		sprite.sprite_frames.add_animation(anim_name)
		sprite.sprite_frames.set_animation_speed(anim_name, 8.0)
		sprite.sprite_frames.set_animation_loop(anim_name, true)
		
		var frame_width = 64 # Assuming 64px width based on previous checks
		var frame_height = texture.get_height()
		
		for i in range(frame_count):
			var atlas = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(i * frame_width, 0, frame_width, frame_height)
			sprite.sprite_frames.add_frame(anim_name, atlas)
	else:
		push_error("Failed to load texture for animation: " + anim_name + " at path: " + path)
