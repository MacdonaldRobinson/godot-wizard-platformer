extends Node2D

onready var platform_body:KinematicBody2D = $KinematicBody2D
onready var hit_area:Area2D = $KinematicBody2D/HitArea

var is_entered_body_owner_group = "player"
var is_entered_body_owner_run_function:FuncRef = funcref(self, "player_entered")
var is_entered_body_owner_run_function_run_in_process = false

var _entered_body

func _ready():
	pass
	
func _physics_process(delta):	
	
	if(is_entered_body_owner_run_function_run_in_process):
		_on_HitArea_body_entered(_entered_body);
	else:
		print("not fun")

func player_entered():
	print("player entered platform")

func _on_HitArea_body_entered(body):
	
	if body != null:
		_entered_body = body
		var owner = body.get_owner()
		if(owner.is_in_group("player")):
			is_entered_body_owner_run_function.call_func(body, platform_body)
