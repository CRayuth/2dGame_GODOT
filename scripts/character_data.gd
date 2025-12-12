extends Resource
class_name CharacterData

# Character data resource
# Defines stats and properties for each character type

@export var character_name: String
@export var character_type: GameManager.CharacterType
@export var hp: int
@export var attack: int
@export var defense: int
@export var speed: int
@export var description: String

static func get_warrior_data() -> CharacterData:
	var warrior = CharacterData.new()
	warrior.character_name = "Warrior"
	warrior.character_type = GameManager.CharacterType.WARRIOR
	warrior.hp = 100
	warrior.attack = 15
	warrior.defense = 10
	warrior.speed = 5
	warrior.description = "A strong and tough fighter with high HP and defense"
	return warrior

static func get_bowman_data() -> CharacterData:
	var bowman = CharacterData.new()
	bowman.character_name = "Bowman"
	bowman.character_type = GameManager.CharacterType.BOWMAN
	bowman.hp = 80
	bowman.attack = 18
	bowman.defense = 6
	bowman.speed = 10
	bowman.description = "A skilled archer with high attack and speed"
	return bowman

static func get_character_data(character_type: GameManager.CharacterType) -> CharacterData:
	match character_type:
		GameManager.CharacterType.WARRIOR:
			return get_warrior_data()
		GameManager.CharacterType.BOWMAN:
			return get_bowman_data()
		_:
			return get_warrior_data()  # Default

