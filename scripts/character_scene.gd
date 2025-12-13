extends Control

@onready var back_button: Button = $back_button_character
@onready var transition_overlay: ColorRect = $TransitionOverlay
@onready var warrior_frame: Panel = $CharacterSelectionContainer/WarriorContainer/WarriorFrame
@onready var warrior_button: Button = $CharacterSelectionContainer/WarriorContainer/WarriorFrame/WarriorButton
@onready var warrior_sprite: AnimatedSprite2D = $CharacterSelectionContainer/WarriorContainer/WarriorFrame/WarriorSprite
@onready var bowman_frame: Panel = $CharacterSelectionContainer/BowmanContainer/BowmanFrame
@onready var bowman_button: Button = $CharacterSelectionContainer/BowmanContainer/BowmanFrame/BowmanButton
@onready var bowman_sprite: AnimatedSprite2D = $CharacterSelectionContainer/BowmanContainer/BowmanFrame/BowmanSprite
@onready var start_game_button: Button = $start_game_button

var selected_character = GameManager.CharacterType.NONE

# StyleBox resources for frame borders
var normal_style: StyleBoxFlat
var selected_style: StyleBoxFlat

func _ready():
	back_button.text = "Go Back"
	
	# Disable start game button initially
	start_game_button.disabled = true
	
	# Create style boxes for frame borders
	normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.2, 0.2, 0.2, 1.0)  # Dark gray background
	normal_style.border_color = Color(0.3, 0.3, 0.3, 1.0)  # Dark border
	normal_style.border_width_left = 3
	normal_style.border_width_top = 3
	normal_style.border_width_right = 3
	normal_style.border_width_bottom = 3
	
	selected_style = StyleBoxFlat.new()
	selected_style.bg_color = Color(0.2, 0.2, 0.2, 1.0)  # Dark gray background
	selected_style.border_color = Color(1.0, 1.0, 1.0, 1.0)  # White border for selected
	selected_style.border_width_left = 4
	selected_style.border_width_top = 4
	selected_style.border_width_right = 4
	selected_style.border_width_bottom = 4
	
	# Load character sprite animations
	load_character_sprites()
	
	# Connect signals for hover effects
	if warrior_button:
		warrior_button.mouse_entered.connect(_on_warrior_mouse_entered)
		warrior_button.mouse_exited.connect(_on_warrior_mouse_exited)
	if bowman_button:
		bowman_button.mouse_entered.connect(_on_bowman_mouse_entered)
		bowman_button.mouse_exited.connect(_on_bowman_mouse_exited)

	# Fade in from black when scene loads
	if transition_overlay:
		transition_overlay.color = Color(0, 0, 0, 1)  # Start black
		var tween = create_tween()
		tween.tween_property(transition_overlay, "color", Color(0, 0, 0, 0), 0.3)
		await tween.finished
		transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Ensure music continues playing in character selection
	if AudioManager != null and AudioManager.current_music_stream == null:
		var music_stream = load("res://audio/background_start_sound.mp3")
		AudioManager.play_music(music_stream, true)
	
	# Wait a frame to ensure all nodes are ready
	await get_tree().process_frame
	
	# Initialize with no character selected
	selected_character = GameManager.CharacterType.NONE
	update_character_frames()

func load_character_sprites():
	# Warrior
	warrior_sprite.sprite_frames = SpriteFrames.new()
	var warrior_idle = load("res://assets/pixel2d/Entities/Characters/Body_A/Animations/Idle_Base/Idle_Side-Sheet.png")
	if warrior_idle:
		add_animation_to_frames(warrior_sprite.sprite_frames, warrior_idle, "idle", 4, 64)
	
	var warrior_action = load("res://assets/pixel2d/Entities/Characters/Body_A/Animations/Slice_Base/Slice_Side-Sheet.png")
	if warrior_action:
		add_animation_to_frames(warrior_sprite.sprite_frames, warrior_action, "action", 8, 64)
	
	warrior_sprite.play("idle")

	# Bowman
	bowman_sprite.sprite_frames = SpriteFrames.new()
	var bowman_idle = load("res://assets/pixel2d/Entities/Characters/Body_A/Animations/Idle_Base/Idle_Side-Sheet.png")
	if bowman_idle:
		add_animation_to_frames(bowman_sprite.sprite_frames, bowman_idle, "idle", 4, 64)
	
	var bowman_action = load("res://assets/pixel2d/Entities/Characters/Body_A/Animations/Pierce_Base/Pierce_Side-Sheet.png")
	if bowman_action:
		add_animation_to_frames(bowman_sprite.sprite_frames, bowman_action, "action", 8, 64)
	
	bowman_sprite.play("idle")

func add_animation_to_frames(frames: SpriteFrames, texture: Texture2D, anim_name: String, frame_count: int, frame_width: int):
	frames.add_animation(anim_name)
	frames.set_animation_speed(anim_name, 8.0)
	frames.set_animation_loop(anim_name, true)
	
	var frame_height = texture.get_height()
	for i in range(frame_count):
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = texture
		atlas_texture.region = Rect2(i * frame_width, 0, frame_width, frame_height)
		frames.add_frame(anim_name, atlas_texture)

func update_character_frames():
	if not warrior_frame or not bowman_frame:
		return
	
	# Update Warrior frame
	if selected_character == GameManager.CharacterType.WARRIOR:
		warrior_frame.add_theme_stylebox_override("panel", selected_style)
		if warrior_sprite:
			warrior_sprite.modulate = Color.WHITE
			warrior_sprite.play("action")
	else:
		warrior_frame.add_theme_stylebox_override("panel", normal_style)
		if warrior_sprite:
			warrior_sprite.modulate = Color(0.7, 0.7, 0.7, 1.0)
			warrior_sprite.play("idle")
	
	# Update Bowman frame
	if selected_character == GameManager.CharacterType.BOWMAN:
		bowman_frame.add_theme_stylebox_override("panel", selected_style)
		if bowman_sprite:
			bowman_sprite.modulate = Color.WHITE
			bowman_sprite.play("action")
	else:
		bowman_frame.add_theme_stylebox_override("panel", normal_style)
		if bowman_sprite:
			bowman_sprite.modulate = Color(0.7, 0.7, 0.7, 1.0)
			bowman_sprite.play("idle")
	
	# Enable start game button when character is selected
	if start_game_button:
		start_game_button.disabled = (selected_character == GameManager.CharacterType.NONE)

func _on_warrior_mouse_entered():
	# Only play action on hover if not selected? OR simple highlight?
	# User said "until player hover". I'll make it play action on hover temporarily
	if selected_character != GameManager.CharacterType.WARRIOR:
		if warrior_sprite:
			warrior_sprite.modulate = Color.WHITE
			warrior_sprite.play("action")

func _on_warrior_mouse_exited():
	if selected_character != GameManager.CharacterType.WARRIOR:
		if warrior_sprite:
			warrior_sprite.modulate = Color(0.7, 0.7, 0.7, 1.0)
			warrior_sprite.play("idle")

func _on_bowman_mouse_entered():
	if selected_character != GameManager.CharacterType.BOWMAN:
		if bowman_sprite:
			bowman_sprite.modulate = Color.WHITE
			bowman_sprite.play("action")

func _on_bowman_mouse_exited():
	if selected_character != GameManager.CharacterType.BOWMAN:
		if bowman_sprite:
			bowman_sprite.modulate = Color(0.7, 0.7, 0.7, 1.0)
			bowman_sprite.play("idle")

func _on_warrior_button_pressed():
	selected_character = GameManager.CharacterType.WARRIOR
	GameManager.set_selected_character(GameManager.CharacterType.WARRIOR)
	update_character_frames()
	print("Warrior selected!")

func _on_bowman_button_pressed():
	selected_character = GameManager.CharacterType.BOWMAN
	GameManager.set_selected_character(GameManager.CharacterType.BOWMAN)
	update_character_frames()
	print("Bowman selected!")

func _on_start_game_button_pressed() -> void:
	if not start_game_button.disabled:
		print("Starting game with: ", GameManager.get_selected_character_name())
		
		# OOP: Persist State
		# Save specific character choice to database before entering game
		GameManager.save_game()
		
		transition_to_scene("res://scenes/gameplay_scene.tscn")

func _on_back_button_character_pressed():
	transition_to_scene("res://scenes/main_menu.tscn")

func transition_to_scene(scene_path: String, fade_duration: float = 0.4):
	if transition_overlay:
		transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
		var tween = create_tween()
		tween.tween_property(transition_overlay, "color", Color(0, 0, 0, 1), fade_duration)
		await tween.finished
	get_tree().change_scene_to_file(scene_path)
