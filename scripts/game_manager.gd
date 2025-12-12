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

func reset_game():
	selected_character = CharacterType.WARRIOR
	has_character_selected = false
