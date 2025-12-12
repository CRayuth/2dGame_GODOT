extends Node

# Settings Manager Singleton
# Handles saving and loading of game settings

const SETTINGS_FILE = "user://settings.cfg"
const SECTION_NAME = "audio"

# Default values
const DEFAULT_MUSIC_VOLUME = 1.0
const DEFAULT_SFX_VOLUME = 1.0

var music_volume: float = DEFAULT_MUSIC_VOLUME
var sfx_volume: float = DEFAULT_SFX_VOLUME
var music_muted: bool = false
var sfx_muted: bool = false

func _ready():
	_ensure_audio_buses_exist()
	load_settings()

func _ensure_audio_buses_exist():
	# Check if Music bus exists, create if not
	var music_bus_id = AudioServer.get_bus_index("Music")
	if music_bus_id == -1:
		# Create Music bus (add at position 1, after Master)
		AudioServer.add_bus(1)
		music_bus_id = 1  # New bus is at index 1
		AudioServer.set_bus_name(music_bus_id, "Music")
		AudioServer.set_bus_send(music_bus_id, "Master")
		print("Created Music audio bus at index ", music_bus_id)
	
	# Check if SFX bus exists, create if not
	var sfx_bus_id = AudioServer.get_bus_index("SFX")
	if sfx_bus_id == -1:
		# Create SFX bus (add after Music bus)
		var insert_position = AudioServer.bus_count
		AudioServer.add_bus(insert_position)
		sfx_bus_id = insert_position
		AudioServer.set_bus_name(sfx_bus_id, "SFX")
		AudioServer.set_bus_send(sfx_bus_id, "Master")
		print("Created SFX audio bus at index ", sfx_bus_id)

func save_settings():
	var config = ConfigFile.new()
	config.set_value(SECTION_NAME, "music_volume", music_volume)
	config.set_value(SECTION_NAME, "sfx_volume", sfx_volume)
	config.set_value(SECTION_NAME, "music_muted", music_muted)
	config.set_value(SECTION_NAME, "sfx_muted", sfx_muted)
	
	var error = config.save(SETTINGS_FILE)
	if error != OK:
		print("Error saving settings: ", error)
	else:
		print("Settings saved successfully")

func load_settings():
	var config = ConfigFile.new()
	var error = config.load(SETTINGS_FILE)
	
	if error != OK:
		# File doesn't exist yet, use defaults
		print("Settings file not found, using defaults")
		apply_audio_settings()
		return
	
	# Load music volume
	if config.has_section_key(SECTION_NAME, "music_volume"):
		music_volume = config.get_value(SECTION_NAME, "music_volume", DEFAULT_MUSIC_VOLUME)
	
	# Load SFX volume
	if config.has_section_key(SECTION_NAME, "sfx_volume"):
		sfx_volume = config.get_value(SECTION_NAME, "sfx_volume", DEFAULT_SFX_VOLUME)
	
	# Load mute states
	if config.has_section_key(SECTION_NAME, "music_muted"):
		music_muted = config.get_value(SECTION_NAME, "music_muted", false)
	if config.has_section_key(SECTION_NAME, "sfx_muted"):
		sfx_muted = config.get_value(SECTION_NAME, "sfx_muted", false)
	
	apply_audio_settings()
	print("Settings loaded: Music=", music_volume, " SFX=", sfx_volume, " MusicMuted=", music_muted, " SFXMuted=", sfx_muted)

func apply_audio_settings():
	# Ensure buses exist before applying
	_ensure_audio_buses_exist()
	
	# Apply music volume (muted = -80dB which is effectively silent)
	var music_bus_id = AudioServer.get_bus_index("Music")
	if music_bus_id != -1:
		if music_muted:
			AudioServer.set_bus_volume_db(music_bus_id, -80.0)
		else:
			AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(music_volume))
	
	# Apply SFX volume (muted = -80dB which is effectively silent)
	var sfx_bus_id = AudioServer.get_bus_index("SFX")
	if sfx_bus_id != -1:
		if sfx_muted:
			AudioServer.set_bus_volume_db(sfx_bus_id, -80.0)
		else:
			AudioServer.set_bus_volume_db(sfx_bus_id, linear_to_db(sfx_volume))

func set_music_volume(value: float, apply: bool = true):
	music_volume = clamp(value, 0.0, 1.0)
	if apply:
		apply_audio_settings()
	save_settings()

func set_sfx_volume(value: float, apply: bool = true):
	sfx_volume = clamp(value, 0.0, 1.0)
	if apply:
		apply_audio_settings()
	save_settings()

func toggle_music_mute():
	music_muted = !music_muted
	apply_audio_settings()
	save_settings()
	return music_muted

func toggle_sfx_mute():
	sfx_muted = !sfx_muted
	apply_audio_settings()
	save_settings()
	return sfx_muted

func set_music_mute(muted: bool):
	music_muted = muted
	apply_audio_settings()
	save_settings()

func set_sfx_mute(muted: bool):
	sfx_muted = muted
	apply_audio_settings()
	save_settings()

func get_music_volume() -> float:
	return music_volume

func get_sfx_volume() -> float:
	return sfx_volume

func is_music_muted() -> bool:
	return music_muted

func is_sfx_muted() -> bool:
	return sfx_muted
