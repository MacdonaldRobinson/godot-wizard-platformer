extends Node2D

onready var sprite_animation = $Sprite/AnimationPlayer

var is_weapon_mode = false setget set_is_weapon_mode
var collector_group_name = "player"

func _ready():
	if(!is_weapon_mode):
		sprite_animation.play("UpDown")

func _on_Area2D_area_entered(area):			
	if(!is_weapon_mode):
		var owner = area.get_owner()	
		if owner != null && owner.is_in_group(collector_group_name):
			queue_free()	

func set_is_weapon_mode(new_val):
	is_weapon_mode = new_val

func _on_VisibilityNotifier2D_screen_exited():
	if(is_weapon_mode):
		queue_free()
