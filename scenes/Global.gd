extends Node

var level_gravity = 9.8
var player_health = 100
var orbs_collected = 0
var player_has_died = false setget set_player_has_died
var player_saybox_text = ""

onready var death_scene = get_tree().get_nodes_in_group("death_scene")[0]
onready var player = get_tree().get_nodes_in_group("player")[0]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func set_player_has_died(new_val):
	player_has_died = new_val	
	
	death_scene = get_tree().get_nodes_in_group("death_scene")[0]
	
	if(player_has_died):
		get_tree().paused = true
		print("Ran set_player_has_died")
		
		if(death_scene != null):
			death_scene.show()
	else:
		get_tree().paused = false
		death_scene.hide()		
	
func raise_event(event_name:String):
	var event = InputEventAction.new()
	event.action = event_name
	event.pressed = false
	Input.parse_input_event(event)		

func restart():
	player_health = 100
	orbs_collected = 0
	player_has_died = false
	player_saybox_text = ""
	get_tree().reload_current_scene()
	get_tree().paused = false
