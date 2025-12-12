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

# Acceleration (how fast to reach max speed)
# Lower value = heavier feel (slower buildup)
@export var acceleration: float = 1500.0

# friction (how fast to stop)
@export var friction: float = 1000.0

# Run speed multiplier
@export var run_speed_multiplier: float = 2.0

# State
var is_running: bool = false

# Reference to the AnimatedSprite2D node
# We use @onready to ensure the node is available before we access it
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# --- Virtual Methods (To be overridden by child classes) ---

# Get input vector. Returns Vector2.ZERO by default.
# Child classes (like Player) should override this to provide input control.
func _get_input_vector() -> Vector2:
	return Vector2.ZERO

# --- Built-in Methods ---

func _physics_process(delta: float) -> void:
	# 1. Get movement direction from the virtual input method
	var direction = _get_input_vector()
	
	# 2. Apply Physics (Acceleration & Friction) using move_toward
	if direction.length() > 0:
		# Determine target speed (Walk vs Run)
		var current_speed = movement_speed
		if is_running:
			current_speed *= run_speed_multiplier
			
		# Normalize direction and accelerate towards target velocity
		var target_velocity = direction.normalized() * current_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Apply friction to slow down to zero
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# 3. Move the character using Godot's built-in physics engine
	move_and_slide()
	
	# 4. Handle animation and sprite orientation
	# We pass velocity instead of direction to match visual movement to actual physics
	_handle_animation(velocity)

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
