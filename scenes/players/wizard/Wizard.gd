extends Node2D

onready var body:KinematicBody2D = $KinematicBody2D
onready var sprite:AnimatedSprite = $KinematicBody2D/AnimatedSprite
onready var animation_player:AnimationPlayer = $KinematicBody2D/AnimatedSprite/AnimationPlayer
onready var camera:Camera2D = $KinematicBody2D/Camera2D

export var smoke_ball = "res://scenes/effects/SmokeBall.tscn"

var SPEED = 100
var MAX_SPEED = 500
var new_position = Vector2(0, 0)
var is_attacking = false
var smoke_balls = []
var smoke_ball_is_flipped_h = false
var taking_damage = false

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	new_position.y += Global.level_gravity
	
	if taking_damage:
		Global.player_health -= 1
		
	if Global.player_health <=0:
		Global.player_has_died = true
	
	for ball in smoke_balls:	
		if(ball == null):			
			smoke_balls.erase(ball)
			
		if(ball != null):	
			if(smoke_ball_is_flipped_h):
				ball.position.x -= 30	
			else:
				ball.position.x += 30	
			add_child(ball)		
						
	
	if(body.position.y > camera.limit_bottom):
		Global.player_has_died = true	
	
	var run_animation = "Run"
	
	if (!body.is_on_floor()):
		run_animation = "Jump"	
	if Global.player_has_died:
		run_animation = "Death"	
	
	if(Input.is_action_pressed("ui_left") && !is_attacking):
		new_position.x -= SPEED
		sprite.flip_h = true
		sprite.play(run_animation)
	elif(Input.is_action_pressed("ui_right") && !is_attacking):
		new_position.x += SPEED
		sprite.flip_h = false
		sprite.play(run_animation)		
	else:
		if(body.is_on_floor() && !is_attacking):
			sprite.play("Idle")
			
		
	if(Input.is_action_pressed("ui_up") && body.is_on_floor()):
		new_position.y -= SPEED	* 5
		sprite.play("Jump")
	elif(Input.is_action_pressed("ui_down") && !body.is_on_floor()):
		new_position.y += SPEED
		sprite.play("Fall")		
	
	if(Input.is_action_just_pressed("ui_attack1") && !is_attacking):
		sprite.play("Attack1")
		is_attacking = true
	elif(Input.is_action_just_pressed("ui_attack2") && !is_attacking):
		sprite.play("Attack2")
		is_attacking = true		
	
	if(!body.is_on_floor() && !is_attacking ):		
		if(new_position.y < 0):
			sprite.play("Jump")	
		else:
			sprite.play("Fall")	
			
	new_position.x = lerp(new_position.x, 0, 0.1) 					
	new_position = body.move_and_slide(new_position, Vector2(0, -1))	


func _on_AnimatedSprite_animation_finished():
	is_attacking = false
	if(sprite.animation == "Attack2"):
		var smoke_ball_instance = load(smoke_ball).instance()
		smoke_ball_instance.position = body.position
		smoke_balls.append(smoke_ball_instance)
		
		smoke_ball_is_flipped_h = sprite.flip_h


func _on_HitArea_area_entered(area):
	var owner = area.get_owner()
	if(owner.is_in_group("enemy")):
		print("enemy entered")
		taking_damage = true
	else:
		if(owner.is_in_group("orb")):
			Global.orbs_collected += 1


func _on_HitArea_area_exited(area):
	var owner = area.get_owner()
	if(owner !=null && owner.is_in_group("enemy")):
		print("enemy exited")
		taking_damage = false
