extends Node2D
class_name Platform

var platform_body:KinematicBody2D
var hit_area:Area2D

var owner_group_name = "player"
var body_entered_run_function:FuncRef = funcref(self, "group_entered")
var body_exited_run_function:FuncRef = funcref(self, "group_exited")

var _entered_body

func _ready():
	for body_test in get_children():
		if(body_test is KinematicBody2D):
			platform_body = body_test
			for area_test in platform_body.get_children():
				if(area_test is Area2D):
					hit_area = area_test	
					
	hit_area.disconnect("body_entered", self, "_on_HitArea_body_entered")
	hit_area.disconnect("body_exited", self, "_on_HitArea_body_exited")
					
	hit_area.connect("body_entered", self, "_on_HitArea_body_entered")
	hit_area.connect("body_exited", self, "_on_HitArea_body_exited")
		

func group_entered(group_body, platform_body):		
	pass
	
func group_exited(group_body, platform_body):
	pass

func _on_HitArea_body_entered(body):	
	if body != null:
		_entered_body = body
		var owner = body.get_owner()
		if(owner !=null && owner.is_in_group(owner_group_name)):
			body_entered_run_function.call_func(body, platform_body)

func _on_HitArea_body_exited(body):	
	if body != null:
		_entered_body = body
		var owner = body.get_owner()
		if(owner !=null && owner.is_in_group(owner_group_name)):
			body_exited_run_function.call_func(body, platform_body)
