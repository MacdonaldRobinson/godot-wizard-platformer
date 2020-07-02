extends Node2D

onready var death_scene = $Overlays/DeathScene
onready var path_platform = $Platforms/Path2D/PathFollow2D/PathPlatform
onready var path_follow_platform:PathFollow2D = $Platforms/Path2D/PathFollow2D

func _ready():	
	path_platform.is_entered_body_owner_group = "player"
	path_platform.is_entered_body_owner_run_function = funcref(self, "player_entered_path_platform")
	path_platform.is_entered_body_owner_run_function_run_in_process = true
	
func _on_Wizard_player_has_died():
	death_scene.show()


func player_entered_path_platform(player_body, platform_body):
	print("player_entered_path_platform")
	print(path_follow_platform.offset)
	var current_offset = path_follow_platform.get_offset()
	path_follow_platform.set_offset( current_offset + 10)
	

func _on_Wizard_orb_collected():
	pass # Replace with function body.
