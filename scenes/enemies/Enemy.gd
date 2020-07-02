extends Node2D

onready var body = $KinematicBody2D
onready var sprite = $KinematicBody2D/AnimatedSprite
onready var ray = $KinematicBody2D/RayCast2D
onready var body_collision = $KinematicBody2D/BodyCollision
onready var attack_area = $KinematicBody2D/AttackArea
onready var floor_check_ray = $KinematicBody2D/FloorCheck
onready var health_bar = $KinematicBody2D/BodyCollision/HealthBar
onready var death_timer = $KinematicBody2D/DeathTimer
onready var death_tween = $KinematicBody2D/DeathTween
onready var stop_alert_timer = $KinematicBody2D/StopAlertTimer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

enum DIRECTION{
	LEFT,
	RIGHT
}

var WALK_SPEED = 20
var FOLLOW_SPEED = 100

var current_speed = WALK_SPEED
var current_animation = "Walk"
var new_position = Vector2(0, 0)
var direction = DIRECTION.RIGHT

var is_dead = false
# Called every frame. 'delta' is the elapsed time since the previous frame.

func set_alert():
	print("set alert")
	current_speed = FOLLOW_SPEED
	stop_alert_timer.start(0)

func _physics_process(delta):
	var snap = Vector2(0, 32)
	sprite.play(current_animation)
	new_position.y += Global.level_gravity	
	
	if(health_bar.value == 0):
		is_dead = true
		sprite.play("Death")				
		body.remove_child(body_collision)
		body.remove_child(attack_area)
		set_physics_process(false)		

	if(sprite.animation != "Hurt"):	
		if(direction == DIRECTION.LEFT):
			new_position.x -= current_speed
		elif(direction == DIRECTION.RIGHT):
			new_position.x += current_speed
		
	if(ray.is_colliding()):
		if(ray.get_collider().get_owner().is_in_group("player")):	
			stop_alert_timer.start(0)
			current_speed = FOLLOW_SPEED
		elif(ray.get_collider().get_owner().is_in_group("enemy")):
			flip_direction()			
			current_speed = WALK_SPEED
			
	if(!floor_check_ray.is_colliding() && !ray.is_colliding()):
		flip_direction()				
#
	new_position.x = lerp(new_position.x, 0, 0.1)
	new_position = body.move_and_slide_with_snap(new_position, snap, Vector2.UP)	
	
func flip_direction():
	var offset = 30		
	ray.cast_to.x *= -1		
	
	if(direction == DIRECTION.LEFT):		
		direction = DIRECTION.RIGHT
		sprite.flip_h = false
		#sprite.position.x += offset
		body_collision.position.x = sprite.position.x - offset
		ray.position.x = sprite.position.x - offset
		attack_area.position.x  = sprite.position.x	- offset
		floor_check_ray.position.x = sprite.position.x + 150
	else:
		direction = DIRECTION.LEFT
		sprite.flip_h = true
		#sprite.position.x -= offset
		body_collision.position.x = sprite.position.x + offset
		ray.position.x = sprite.position.x + offset
		attack_area.position.x  = sprite.position.x + offset
		floor_check_ray.position.x = sprite.position.x - 150

func _on_FlipDirection_timeout():
	flip_direction()

func _on_AttackArea_body_entered(entered_body):		
	var owner = entered_body.get_owner()
	if(owner != null && owner.is_in_group("player")):
		current_animation = "Attack"
		set_alert()

func _on_AttackArea_body_exited(exited_body):	
	var owner = exited_body.get_owner()
	if(owner!= null && owner.is_in_group("player")):
		flip_direction()
		set_alert()

func _on_AttackArea_area_shape_entered(area_id, area, area_shape, self_shape):
	var owner = area.get_owner();	
	if(owner != null && owner.is_in_group("weapon") && owner.is_weapon_mode):
		current_animation = "Hurt"
		health_bar.value = 0
		
func _on_AnimatedSprite_animation_finished():
	if(sprite.animation == "Hurt"):
		current_animation = "Walk"
	elif(sprite.animation == "Death"):
		death_tween.reset_all()
		death_tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2.0, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
		death_tween.start()
		
		death_timer.start()

func _on_DeathTimer_timeout():
	queue_free()


func _on_StopAlertTimer_timeout():
	current_speed = WALK_SPEED
	current_animation = "Walk"
	print("No longer Alert")
