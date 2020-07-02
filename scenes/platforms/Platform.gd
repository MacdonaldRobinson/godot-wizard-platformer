extends Node2D

export onready var platform_body:KinematicBody2D = $KinematicBody2D
export onready var hit_area:Area2D = $KinematicBody2D/HitArea

var is_entered_body_owner_group = "player"
var is_entered_body_owner_run_function:FuncRef = funcref(self, "player_entered")
var is_exited_body_owner_run_function:FuncRef = funcref(self, "player_exited")

var _entered_body

func _ready():
	pass

func player_entered(body, platform_body):	
	print("player entered platform")
	
func player_exited(body, platform_body):
	print("player exited platform")

func _on_HitArea_body_entered(body):
	if body != null:
		_entered_body = body
		var owner = body.get_owner()
		if(owner.is_in_group("player")):
			is_entered_body_owner_run_function.call_func(body, platform_body)

func _on_HitArea_body_exited(body):	
	if body != null:
		_entered_body = body
		var owner = body.get_owner()
		if(owner.is_in_group("player")):
			is_exited_body_owner_run_function.call_func(body, platform_body)
