extends Control
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var setting_background: Panel = $Setting_Background
@onready var music_control: HSlider = $Setting_Background/MusicControl
@onready var music_mute_button: Button = $Setting_Background/MusicMuteButton
@onready var transition_overlay: ColorRect = $TransitionOverlay

func _ready():
	# this is to open the Mainbutton and close the setting background
	main_buttons.visible = true
	setting_background.visible = false
	
	# Initialize transition overlay
	if transition_overlay:
		transition_overlay.color = Color(0, 0, 0, 0)
		transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Fade in from black when scene loads
		fade_in_scene(0.3)
	
	# Update mute button states
	update_mute_buttons()
	
	# Start background music through AudioManager if available
	if AudioManager != null:
		var music_stream = load("res://audio/background_start_sound.mp3")
		AudioManager.play_music(music_stream, true)

func update_mute_buttons():
	if SettingsManager != null:
		music_mute_button.text = "Mute" if not SettingsManager.is_music_muted() else "Unmute"
		
		# Also update the volume controls to reflect mute state
		if music_control:
			music_control.update_volume(music_control.value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_new_game_pressed() -> void:
	print("Start new game")
	transition_to_scene("res://scenes/character_scene.tscn")
	pass # Replace with function body.

func transition_to_scene(scene_path: String, fade_duration: float = 0.4):
	# Fade out to black
	if transition_overlay:
		transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP  # Block input during transition
		var tween = create_tween()
		tween.tween_property(transition_overlay, "color", Color(0, 0, 0, 1), fade_duration)
		await tween.finished
	
	# Change scene
	get_tree().change_scene_to_file(scene_path)

func fade_in_scene(duration: float = 0.3):
	# Fade in from black (used when scene first loads)
	if transition_overlay:
		transition_overlay.color = Color(0, 0, 0, 1)  # Start black
		var tween = create_tween()
		tween.tween_property(transition_overlay, "color", Color(0, 0, 0, 0), duration)
		await tween.finished
		transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_continue_game_pressed() -> void:
	print("Continue game")
	pass # Replace with function body.


func _on_setting_game_pressed() -> void:
	print("Setting")
	# this is to open the setting background and close the main button
	main_buttons.visible = false
	setting_background.visible = true
	update_mute_buttons()

# this function is to press to go back to the starting game menu
func _on_back_pressed() -> void:
	_ready()


func _on_exit_game_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

func _on_music_mute_button_pressed() -> void:
	if SettingsManager != null:
		SettingsManager.toggle_music_mute()
		update_mute_buttons()
