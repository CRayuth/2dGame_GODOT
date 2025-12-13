extends CharacterBody2D
class_name CharacterBody

# --- OOP: Observer Pattern (Signals) ---
# We use signals to notify the UI when stats change. 
# This decouples the Character (Model) from the UI (View).
signal health_changed(new_value: int, max_value: int)
signal stamina_changed(new_value: float, max_value: float)

# --- Properties ---

# Character stats
@export var movement_speed: float = 200.0
@export var hp: int = 100
@export var max_hp: int = 100

# Stamina System
@export var max_stamina: float = 100.0
var current_stamina: float = 100.0
@export var stamina_drain_rate: float = 20.0
@export var stamina_regen_rate: float = 10.0

# Acceleration (how fast to reach max speed)
# Lower value = heavier feel (slower buildup)
@export var acceleration: float = 1000.0

# friction (how fast to stop)
@export var friction: float = 1000.0

# Run speed multiplier
@export var run_speed_multiplier: float = 1.5

# State
var is_running: bool = false

# Reference to the AnimatedSprite2D node
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Initialize stats
	current_stamina = max_stamina

# --- Virtual Methods (To be overridden by child classes) ---

# Get input vector. Returns Vector2.ZERO by default.
func _get_input_vector() -> Vector2:
	return Vector2.ZERO

# --- Built-in Methods ---

func _physics_process(delta: float) -> void:
	# 1. Get movement direction from the virtual input method
	var direction = _get_input_vector()
	
	# 2. Handle Stamina Logic
	_handle_stamina(delta, direction)
	
	# 3. Apply Physics (Acceleration & Friction) using move_toward
	if direction.length() > 0:
		# Determine target speed (Walk vs Run)
		var current_speed = movement_speed
		
		# Only run if we have stamina and are creating input
		if is_running and current_stamina > 0:
			current_speed *= run_speed_multiplier
			
		# Normalize direction and accelerate towards target velocity
		var target_velocity = direction.normalized() * current_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Apply friction to slow down to zero
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# 4. Move the character using Godot's built-in physics engine
	move_and_slide()
	
	# 5. Handle animation and sprite orientation
	_handle_animation(velocity)

# --- Helper Methods ---

func _handle_stamina(delta: float, direction: Vector2) -> void:
	var old_stamina = current_stamina
	var is_moving = direction.length() > 0
	
	if is_running and is_moving and current_stamina > 0:
		# Drain stamina when running and moving
		current_stamina -= stamina_drain_rate * delta
	else:
		# Regenerate stamina when not running or stationary
		if current_stamina < max_stamina:
			current_stamina += stamina_regen_rate * delta
	
	# Clamp and Emit Signal if changed
	current_stamina = clamp(current_stamina, 0, max_stamina)
	
	if current_stamina != old_stamina:
		stamina_changed.emit(current_stamina, max_stamina)

# Handles sprite flipping and animation playback based on movement
func _handle_animation(velocity_vector: Vector2) -> void:
	if not sprite:
		return
		
	# Flip sprite horizontally based on velocity
	if velocity_vector.x != 0:
		sprite.flip_h = (velocity_vector.x < 0)
	
	# Play animations based on movement state
	if velocity_vector.length() > 0:
		# If moving, play 'walk' or 'run' animation if available, otherwise 'idle'
		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		# If stopped, play 'idle' animation
		sprite.play("idle")
