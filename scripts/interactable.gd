class_name Interactable
extends Node2D

# ------------------------------------------------------------------------------
# Interactable Base Class (OOP: Abstraction/Inheritance)
# ------------------------------------------------------------------------------
# Base class for all objects the player can interact with (Chests, NPCs, Signs).
# Subclasses must override the interact() method.
# ------------------------------------------------------------------------------

func interact(_player: Player) -> void:
	push_warning("Interact method not implemented in " + name)
