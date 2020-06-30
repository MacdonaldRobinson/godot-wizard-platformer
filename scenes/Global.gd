extends Node

var level_gravity = 9.8
var player_health = 100
var orbs_collected = 0
var player_has_died = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func restart():
	player_health = 100
	orbs_collected = 0
	player_has_died = false
	get_tree().reload_current_scene()
	get_tree().paused = false
