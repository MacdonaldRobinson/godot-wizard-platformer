extends Node2D

onready var sprite_animation = $Sprite/AnimationPlayer
onready var amount_label = $Sprite/Amount

export var store_name = "collectable"
export var show_labels = true
export var amount = 1
export var before_label = "+"
export var after_label = ""

var is_weapon_mode = false setget set_is_weapon_mode
var collector_group_name = "player"

func _ready():
	if(show_labels):
		amount_label.text = before_label+str(amount)+after_label
	else:
		amount_label.hide()
		
	if(!is_weapon_mode):
		sprite_animation.play("UpDown")

func _on_Area2D_area_entered(area):			
	if(!is_weapon_mode):
		var owner = area.get_owner()	
		if owner != null && owner.is_in_group(collector_group_name):
			Global.increase_store_item_by(store_name, amount)			
			queue_free()	

func set_is_weapon_mode(new_val):
	is_weapon_mode = new_val
	show_labels = false

func _on_VisibilityNotifier2D_screen_exited():
	if(is_weapon_mode):
		queue_free()
