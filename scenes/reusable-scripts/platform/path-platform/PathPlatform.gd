extends Node2D
class_name PathPlatform

var path:Path2D 
var path_follow:PathFollow2D
var platform:Platform
var pause_timer:Timer = Timer.new()

export var activate_for_group_name = "player"
export var pause_time = 1
export var platform_move_speed = 5
export var one_way = true
export var only_move_when_group_enters = true

enum RESET_BEHAVIOUR{
	NONE,	
	START,
	END
	START_OR_END,	
}

export (RESET_BEHAVIOUR) var reset_behaviour = RESET_BEHAVIOUR.START_OR_END

func _ready():	
	for path_test in get_children():	
		if(path_test is Timer):			
			pause_timer = path_test	
		elif(path_test is Path2D):			
			path = path_test			
			for pathfollow_test in path.get_children():	
				if(pathfollow_test is PathFollow2D):							
					pathfollow_test.rotation_degrees = 0
					pathfollow_test.loop = false
					pathfollow_test.rotation = false
					path_follow = pathfollow_test
					for platform_test in path_follow.get_children():	
						if(platform_test is Platform):
							platform = platform_test
							
	pause_timer.wait_time = pause_time
	pause_timer.connect("timeout", self, "_on_PauseTimer_timeout")
	add_child(pause_timer)

	if(platform is Platform):		
		platform.owner_group_name = activate_for_group_name
		platform.body_entered_run_function = funcref(self, "group_entered_path_platform")
		platform.body_exited_run_function = funcref(self, "group_exited_path_platform")	

var is_group_on_platform = false

var group_body 
var platform_body

enum DIRECTION {
	FORWARD,
	BACKWARD
}

var move_direction = DIRECTION.FORWARD
var can_move = true
var is_resetting = false

func _get_is_end_of_path():
	return path_follow.get_unit_offset() == 1
	
func _get_is_start_of_path():
	return path_follow.get_unit_offset() == 0	
	
func _get_current_unit_offset():
	return path_follow.get_unit_offset()

func _physics_process(delta):	
	group_entered_path_platform_process()		

func group_entered_path_platform(player_body, platform_body):
	group_body = group_body
	platform_body = platform_body
	is_group_on_platform = true	
			
func group_entered_path_platform_process():	
	if !is_resetting:		
		if(!is_group_on_platform && only_move_when_group_enters):
			can_move = false			
		else:				
			if(_get_is_end_of_path() && one_way):
				can_move = false
			else:
				can_move = true
	else:
		can_move = true
	
	var current_offset = path_follow.get_offset()	
			
	if can_move:
		if(move_direction == DIRECTION.FORWARD):		
			path_follow.set_offset(current_offset + platform_move_speed)
		if(move_direction == DIRECTION.BACKWARD):
			path_follow.set_offset(current_offset - platform_move_speed)	
				
	if(_get_is_start_of_path()):
		move_direction = DIRECTION.FORWARD
		is_resetting = false
		set_physics_process(false)
		pause_timer.start(0)
	elif(_get_is_end_of_path()):
		move_direction = DIRECTION.BACKWARD			
		is_resetting = false	
		set_physics_process(false)
		pause_timer.start(0)
	else:
		if(reset_behaviour != RESET_BEHAVIOUR.NONE && !is_group_on_platform && only_move_when_group_enters):
			if(!is_resetting):			
				is_resetting = true					
				match reset_behaviour:
					RESET_BEHAVIOUR.START:
						move_direction = DIRECTION.BACKWARD
					RESET_BEHAVIOUR.END:
						move_direction = DIRECTION.FORWARD
					RESET_BEHAVIOUR.START_OR_END:				
						if(_get_current_unit_offset() > 0.5):
							move_direction = DIRECTION.FORWARD
						else:
							move_direction = DIRECTION.BACKWARD
							

func group_exited_path_platform(player_body, platform_body):
	is_group_on_platform = false	


func _on_PauseTimer_timeout():
	set_physics_process(true)
