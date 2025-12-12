extends HSlider

@export var audio_bus_name: String

var audio_bus_id
var is_initializing: bool = true

func _ready():
	# Wait for SettingsManager to be ready (it creates buses if needed)
	if SettingsManager == null:
		await get_tree().process_frame
		await get_tree().process_frame  # Extra frame to ensure buses are created
	
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	
	# Verify bus exists
	if audio_bus_id == -1:
		push_error("Audio bus '" + audio_bus_name + "' not found!")
		return
	
	# Load saved volume from SettingsManager
	if SettingsManager != null:
		var saved_volume: float = 1.0
		if audio_bus_name == "Music":
			saved_volume = SettingsManager.get_music_volume()
		elif audio_bus_name == "SFX":
			saved_volume = SettingsManager.get_sfx_volume()
		
		# Set the slider value without triggering value_changed signal
		is_initializing = true
		value = saved_volume
		# Now apply the volume directly to audio bus
		_apply_volume_to_bus(saved_volume)
		is_initializing = false

func _apply_volume_to_bus(vol: float):
	# Verify bus is valid
	if audio_bus_id == -1:
		audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
		if audio_bus_id == -1:
			push_error("Cannot apply volume: Audio bus '" + audio_bus_name + "' not found!")
			return
	
	# Check if muted - if so, don't apply volume change but still save the value
	var is_muted = false
	if SettingsManager != null:
		if audio_bus_name == "Music":
			is_muted = SettingsManager.is_music_muted()
		elif audio_bus_name == "SFX":
			is_muted = SettingsManager.is_sfx_muted()
	
	if is_muted:
		# When muted, set to -80dB (effectively silent)
		AudioServer.set_bus_volume_db(audio_bus_id, -80.0)
	else:
		var db = linear_to_db(vol)
		AudioServer.set_bus_volume_db(audio_bus_id, db)

func _on_value_changed(new_value: float) -> void:
	if is_initializing:
		return
	
	# Immediately apply the volume change to audio bus
	_apply_volume_to_bus(new_value)
	
	# Update SettingsManager's stored value and save (but don't let it reapply and overwrite)
	if SettingsManager != null:
		if audio_bus_name == "Music":
			SettingsManager.music_volume = clamp(new_value, 0.0, 1.0)
			SettingsManager.save_settings()
		elif audio_bus_name == "SFX":
			SettingsManager.sfx_volume = clamp(new_value, 0.0, 1.0)
			SettingsManager.save_settings()

func update_volume(vol: float):
	# Called externally to update slider without triggering save
	is_initializing = true
	value = vol
	_apply_volume_to_bus(vol)
	is_initializing = false
