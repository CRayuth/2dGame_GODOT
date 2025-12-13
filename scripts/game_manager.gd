extends Node

# Game Manager Singleton
# Manages game state and selected character

enum CharacterType {
	NONE = -1,
	WARRIOR,
	BOWMAN
}

var selected_character: CharacterType = CharacterType.NONE  # Default to None
var has_character_selected: bool = false

func set_selected_character(character: CharacterType):
	selected_character = character
	has_character_selected = true
	print("Character selected: ", CharacterType.keys()[character])

func get_selected_character() -> CharacterType:
	return selected_character

func get_selected_character_name() -> String:
	match selected_character:
		CharacterType.WARRIOR:
			return "Warrior"
		CharacterType.BOWMAN:
			return "Bowman"
		_:
			return "Unknown"

const SAVE_FILE_PATH = "user://savegame.cfg"
const SAVE_SECTION = "Player"
const SAVE_KEY_CHARACTER = "Character"

# ------------------------------------------------------------------------------
# OOP Pattern: Singleton / Manager
# ------------------------------------------------------------------------------
# These methods provide a public interface for the Persistence Layer.
# Other classes do not need to know HOW data is saved (encapsulation),
# they just call these methods.
# ------------------------------------------------------------------------------

# Saves the current game state (selected character) to persistent storage
func save_game() -> void:
	var config = ConfigFile.new()
	
	# Serialize data: Map the enum value to the config file
	config.set_value(SAVE_SECTION, SAVE_KEY_CHARACTER, selected_character)
	
	# Write to disk
	var error = config.save(SAVE_FILE_PATH)
	if error != OK:
		push_error("Failed to save game data. Error code: " + str(error))
	else:
		print("Game saved successfully. Character: ", get_selected_character_name())

# Loads game state from persistent storage
# Returns true if load was successful, false otherwise
func load_game() -> bool:
	var config = ConfigFile.new()
	var error = config.load(SAVE_FILE_PATH)
	
	if error != OK:
		print("No save file found or failed to load. Error code: " + str(error))
		return false
	
	# Deserialize data: Read value and update state
	# We provide a default value (NONE) in case the key is missing
	var loaded_character_val = config.get_value(SAVE_SECTION, SAVE_KEY_CHARACTER, CharacterType.NONE)
	
	# Validate loaded data (Defense programming)
	if loaded_character_val in CharacterType.values():
		selected_character = loaded_character_val as CharacterType
		has_character_selected = (selected_character != CharacterType.NONE)
		print("Game loaded successfully. Character: ", get_selected_character_name())
		return true
	else:
		push_error("Loaded invalid character type data.")
		return false

# Checks if a valid save file exists
# Useful for UI (enabling/disabling Continue button)
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func reset_game():
	selected_character = CharacterType.WARRIOR
	has_character_selected = false
