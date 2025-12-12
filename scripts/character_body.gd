class_name CharacterBody
extends CharacterBody2D

# ------------------------------------------------------------------------------
# CharacterBody Base Class
# ------------------------------------------------------------------------------
# This class serves as the parent class for all moving characters in the game
# (e.g., Player, Enemies, NPCs). It adheres to OOP principles by encapsulating
# shared logic for movement, stats, and animation.
# ------------------------------------------------------------------------------

# --- Properties ---

# Movement speed in pixels per second
@export var movement_speed: float = 200.0

# Character health points
@export var hp: int = 100

# Reference to the AnimatedSprite2D node
# We use @onready to ensure the node is available before we access it
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# --- Virtual Methods (To be overridden by child classes) ---

# Get input vector. Returns Vector2.ZERO by default.
# Child classes (like Player) should override this to provide input control.
func _get_input_vector() -> Vector2:
	return Vector2.ZERO

# --- Built-in Methods ---

func _physics_process(_delta: float) -> void:
	# 1. Get movement direction from the virtual input method
	var direction = _get_input_vector()
	
	# 2. Normalize direction to prevent faster diagonal movement
	if direction.length() > 0:
		direction = direction.normalized()
	
	# 3. Apply velocity
	velocity = direction * movement_speed
	
	# 4. Move the character using Godot's built-in physics engine
	move_and_slide()
	
	# 5. Handle animation and sprite orientation
	_handle_animation(direction)

# --- Helper Methods ---

# Handles sprite flipping and animation playback based on movement
func _handle_animation(direction: Vector2) -> void:
	if not sprite:
		return
		
	# Flip sprite horizontally based on direction
	if direction.x != 0:
		sprite.flip_h = (direction.x < 0)
	
	# Play animations based on movement state
	if direction.length() > 0:
		# If moving, play 'walk' or 'run' animation if available, otherwise 'idle'
		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		# If stopped, play 'idle' animation
		sprite.play("idle")
