extends Node2D

onready var path_follow:PathFollow2D = $Path2D/PathFollow2D
onready var path2d = $Path2D
onready var platform = $Path2D/PathFollow2D/Platform
onready var pause_timer:Timer = $PauseTimer

export var pause_time = 1
export var platform_move_speed = 5
export var one_way = true

func _ready():	
	for child in get_children():
		var test_path_follow = child.get_child(0)
		if(child is Path2D && child != path2d && test_path_follow is PathFollow2D):	
			path_follow.remove_child(platform)		
			(test_path_follow as PathFollow2D).add_child(platform)
			path_follow = test_path_follow			
			print(platform.get_parent().get_parent().name)
			
	pause_timer.wait_time = pause_time
	
	platform.is_entered_body_owner_group = "player"
	platform.is_entered_body_owner_run_function = funcref(self, "player_entered_path_platform")
	platform.is_exited_body_owner_run_function = funcref(self, "player_exited_path_platform")	

var direction_flipped = false
var is_player_on_platform = false
var player_body 
var platform_body

func _physics_process(delta):
	if(is_player_on_platform):
		player_entered_path_platform_process()


func player_entered_path_platform(player_body, platform_body):	
	player_body = player_body
	platform_body = platform_body
	is_player_on_platform = true	
			
func player_entered_path_platform_process():
	var current_offset = path_follow.get_offset()	
	
	if(!direction_flipped && path_follow.get_unit_offset() == 1):
		if(!one_way):
			direction_flipped = true
			pause_timer.start()
		set_physics_process(false)
		print("flipped true")
	elif(direction_flipped && path_follow.get_unit_offset() == 0):
		if(!one_way):
			direction_flipped = false
			pause_timer.start()
		print("flipped false")
		set_physics_process(false)
		
	if(!direction_flipped):
		path_follow.set_offset(current_offset + platform_move_speed)
	else:
		path_follow.set_offset(current_offset - platform_move_speed)	
		

func player_exited_path_platform(player_body, platform_body):
	is_player_on_platform = false


func _on_PauseTimer_timeout():
	set_physics_process(true)
