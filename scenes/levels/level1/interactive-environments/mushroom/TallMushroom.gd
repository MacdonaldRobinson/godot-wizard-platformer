extends Node2D


func _ready():
	pass # Replace with function body.

var entered_body:KinematicBody2D
var new_position = Vector2()

func _physics_process(delta):
	if entered_body == null:
		return
		
	print(entered_body.position)
	
	entered_body.position.y-= 10

func _on_Area2D_body_entered(body):
	var owner = body.get_owner();
	if(owner != null && owner.is_in_group("player")):
		entered_body = body


func _on_Area2D_body_exited(body):
	var owner = body.get_owner();
	if(owner != null && owner.is_in_group("player")):
		pass
		#entered_body = null
