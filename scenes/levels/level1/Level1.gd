extends Node2D

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):	
#	pass

onready var death_scene = $Overlays/DeathScene

func _on_Wizard_player_has_died():
	death_scene.show()


func _on_Wizard_orb_collected():
	pass # Replace with function body.
