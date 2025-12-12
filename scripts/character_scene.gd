extends Control

@onready var back_button: Button = $back_button_character
@onready var transition_overlay: ColorRect = $TransitionOverlay

func _ready():
	back_button.text = "Go Back"
	
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


func _on_start_game_button_pressed() -> void:
	pass 


func _on_back_button_character_pressed():
	transition_to_scene("res://scenes/main_menu.tscn")

func transition_to_scene(scene_path: String, fade_duration: float = 0.4):
	# Fade out to black
	if transition_overlay:
		transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP  # Block input during transition
		var tween = create_tween()
		tween.tween_property(transition_overlay, "color", Color(0, 0, 0, 1), fade_duration)
		await tween.finished
	
	# Change scene
	get_tree().change_scene_to_file(scene_path)
