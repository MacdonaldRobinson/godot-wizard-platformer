extends Node2D

onready var death_scene = $Overlays/DeathScene

func _on_Wizard_player_has_died():
	death_scene.show()
