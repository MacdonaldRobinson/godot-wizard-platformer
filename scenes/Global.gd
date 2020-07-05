extends Node

var level_gravity = 9.8
var player_health = 100
var player_has_died = false setget set_player_has_died
var player_saybox_text = ""

var _store = {}

onready var death_scene
onready var player
# Called when the node enters the scene tree for the first time.
func _ready():
	var death_scenes = get_tree().get_nodes_in_group("death_scene")
	var players = get_tree().get_nodes_in_group("death_scene")
	
	if(death_scenes.size() > 1):
		death_scene = death_scenes[0]
		
	if(players.size() > 1):
		player = get_tree().get_nodes_in_group("player")[0]
	
func set_store_item(item_name:String, item_value:int):
	_store[item_name] = item_value

func get_store_item(item_name:String):
	if(_store.has(item_name)):
		return _store[item_name]
	else:
		set_store_item(item_name, 0)
		return _store[item_name]

func get_store():
	return _store	
	
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
	_store = {}
	player_has_died = false
	player_saybox_text = ""
	get_tree().reload_current_scene()
	get_tree().paused = false

