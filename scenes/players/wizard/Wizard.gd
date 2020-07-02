extends Node2D

onready var body:KinematicBody2D = $KinematicBody2D
onready var sprite:AnimatedSprite = $KinematicBody2D/AnimatedSprite
onready var camera:Camera2D = $KinematicBody2D/Camera2D
onready var saybox_container:ColorRect = $KinematicBody2D/SayBoxContainer
onready var saybox:Label = $KinematicBody2D/SayBoxContainer/SayBox
onready var saybox_timer:Timer = $KinematicBody2D/SayBoxTimer
onready var saybox_tween:Tween = $KinematicBody2D/SayBoxContainer/Tween
onready var health_bar:TextureProgress = $KinematicBody2D/HealthBar
onready var hit_area:Area2D = $KinematicBody2D/HitArea

onready var weapon_orb_scene = "res://scenes/collectables/orb/Orb.tscn";

var SPEED = 100
var MAX_SPEED = 500
var new_position = Vector2(0, 0)
var is_attacking = false
var projectiles = []
var projectile_is_flipped_h = false
var taking_damage = false


func say(text:String):
	saybox.text = text	
	
	var length = text.length()
	var duration = 0.05 * length;
	
	saybox_timer.wait_time = duration + 2
	
	saybox_tween.remove_all()
	saybox_tween.interpolate_property(saybox, "percent_visible", 0, 1, duration)	
	saybox_tween.start()
		
	saybox_container.show()
	saybox_timer.start()	

var saybox_original_position
func _ready():
	saybox_original_position = saybox_container.rect_position;
	saybox_container.hide()

func _unhandled_input(event):
	var run_attack = false		
	if(event is InputEventAction):		
		if(event.action == "ui_attack1"):			
			run_attack = true		
		
	if((Input.is_action_just_pressed("ui_attack1") || run_attack) && !is_attacking):
		
		sprite.play("Attack1")
		is_attacking = true
	elif((Input.is_action_just_pressed("ui_attack2") || run_attack) && !is_attacking):
		sprite.play("Attack2")
		is_attacking = true		

var saybox_container_flip_h = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):	
	
	var snap = Vector2(0, 32)
	
	health_bar.value = Global.player_health
	new_position.y += Global.level_gravity
	
	if(sprite.flip_h && !saybox_container_flip_h):
		saybox_container.rect_position.x  *= -1
		saybox_container.rect_position.x -= saybox_container.rect_size.x
		saybox_container_flip_h = true
	elif !sprite.flip_h && saybox_container_flip_h:
		saybox_container.rect_position.x  = saybox_original_position.x
		saybox_container_flip_h = false
	
	if(Global.player_saybox_text != "" and Global.player_saybox_text != saybox.text):
		say(Global.player_saybox_text)

	if taking_damage:
		Global.player_health -= 1
		
	if Global.player_health <=0:
		Global.player_has_died = true
	
	
	for projectile in projectiles:			
		if(projectile == null):			
			projectiles.erase(projectile)

		if(projectile != null):				
			if(projectile_is_flipped_h):
				projectile.position.x -= 30	
			else:
				projectile.position.x += 30					
			
	
	if(body.position.y > camera.limit_bottom):
		Global.player_has_died = true
		set_physics_process(false)
	
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
		snap.y = 0
	elif(Input.is_action_pressed("ui_down") && !body.is_on_floor()):
		new_position.y += SPEED
		sprite.play("Fall")		
	
	
	if(!body.is_on_floor() && !is_attacking ):		
		if(new_position.y < 0):
			sprite.play("Jump")	
		else:
			sprite.play("Fall")	
			
	new_position.x = lerp(new_position.x, 0, 0.1) 		
	new_position = body.move_and_slide_with_snap(new_position, snap, Vector2.UP)	


func _on_AnimatedSprite_animation_finished():
	is_attacking = false


func _on_HitArea_area_entered(area):	
	var owner = area.get_owner()	
	if(owner.is_in_group("enemy") && !owner.is_dead):
		print("enemy entered")
		taking_damage = true
	else:
		if(owner.is_in_group("orb") && !owner.is_weapon_mode):
			Global.orbs_collected += 1


func _on_HitArea_area_exited(area):
	var owner = area.get_owner()
	if(owner !=null && owner.is_in_group("enemy")):
		print("enemy exited")
		taking_damage = false


func _on_Timer_timeout():
	print("Ran timer")
	saybox_container.hide()
	saybox_timer.stop()


func _on_SayBoxContainer_visibility_changed():
	print("visibility changed")
	if(saybox_container.visible):
		saybox_timer.start()


func _on_AnimatedSprite_frame_changed():
	if(sprite.animation == "Attack1" && sprite.get_frame() == 5 && Global.orbs_collected > 0):
		projectile_is_flipped_h = sprite.flip_h
		
		var weapon_orb_scene_instance = load(weapon_orb_scene).instance()
		weapon_orb_scene_instance.is_weapon_mode = true
		weapon_orb_scene_instance.position = body.position
		
		if(projectile_is_flipped_h):
			weapon_orb_scene_instance.position.x -= 50
		else:
			weapon_orb_scene_instance.position.x += 50
			
		weapon_orb_scene_instance.position.y -= 20
		projectiles.append(weapon_orb_scene_instance)	
		add_child(weapon_orb_scene_instance)
			
		Global.orbs_collected -=1
		
