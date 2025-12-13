extends CanvasLayer

# --- UI References ---
@onready var name_label: Label = $Panel/VBoxContainer/NameLabel
@onready var hp_bar: ProgressBar = $Panel/VBoxContainer/HPBar
@onready var stamina_bar: ProgressBar = $Panel/VBoxContainer/StaminaBar

# --- Setup ---
func setup(character_name: String, max_hp: int, max_stamina: float) -> void:
	name_label.text = character_name
	
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	
	stamina_bar.max_value = max_stamina
	stamina_bar.value = max_stamina

# --- Update Methods (Connected to Signals) ---

func update_health(new_value: int, _max_value: int) -> void:
	hp_bar.value = new_value

func update_stamina(new_value: float, _max_value: float) -> void:
	stamina_bar.value = new_value
