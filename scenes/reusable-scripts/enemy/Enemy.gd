extends Node2D

onready var body = $KinematicBody2D
onready var effects = $KinematicBody2D/Effects
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
enum DIRECTION{
	LEFT,
	RIGHT
}

export var WALK_SPEED = 50
export var FOLLOW_SPEED = 100
export var damage_per_attack = 1
export var initial_health_value = 100
export var max_health_value = 100

var current_speed = WALK_SPEED
var current_animation = "Walk"
var new_position = Vector2(0, 0)
var direction = DIRECTION.RIGHT

export var run_effect_at_frame = 2

var is_dead = false
var attack_group_name = "player"

func _ready():
	health_bar.max_value = max_health_value
	health_bar.value = initial_health_value

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
		var collider = ray.get_collider()
		var owner = collider.get_owner();
		if(owner.is_in_group(attack_group_name)):	
			stop_alert_timer.start(0)
			current_speed = FOLLOW_SPEED			
		elif(ray.get_collider().get_owner().is_in_group("enemy")):
			flip_direction()		
			current_speed = WALK_SPEED

	if(!floor_check_ray.is_colliding() && !ray.is_colliding()):
		flip_direction()

	new_position.x = lerp(new_position.x, 0, 0.1)
	new_position = body.move_and_slide_with_snap(new_position, snap, Vector2.UP)	
	
func flip_all(node):
	if(node.get("flip_h") != null):
		node.flip_h = !node.flip_h
		
	if(node.get("position") != null):
		node.position *= -1	
		
	if(node.get("cast_to") != null):
		node.cast_to *= -1
		
	for child_node in node.get_children():
		flip_all(child_node)
	
func flip_direction():
	var offset = 30		
	ray.cast_to.x *= -1	
		
	if(effects != null):
		effects.position *= -1
	
	if(direction == DIRECTION.LEFT):		
		direction = DIRECTION.RIGHT
		sprite.flip_h = false
		#sprite.position.x += offset
		body_collision.position.x = sprite.position.x
		ray.position.x = sprite.position.x
		attack_area.position.x  = sprite.position.x	
		floor_check_ray.position.x = ray.cast_to.x  / 2				
		
		if(effects != null):
			effects.position.x = sprite.position.x + 100
	else:
		direction = DIRECTION.LEFT
		sprite.flip_h = true
		#sprite.position.x -= offset
		body_collision.position.x = sprite.position.x
		ray.position.x = sprite.position.x + offset
		attack_area.position.x  = sprite.position.x
		floor_check_ray.position.x =  ray.cast_to.x  / 2
		
		if(effects != null):
			effects.position.x = sprite.position.x - 100
		
	if(effects != null):
		effects.flip_h = sprite.flip_h
	
func _on_FlipDirection_timeout():
	flip_direction()
	pass
	
func _on_AttackArea_area_entered(area):
	var owner = area.get_owner()
	if(owner != null):
		if(owner.is_in_group(attack_group_name)):
			current_animation = "Attack"
			set_alert()			
		if(owner.get("is_weapon_mode") == true):			
			current_animation = "Hurt"
			health_bar.value -= owner.get("attack_damage")			

		
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


func _on_AttackArea_area_exited(area):
	var owner = area.get_owner()
	if owner!= null:
		if(owner.is_in_group(attack_group_name)):			
			set_alert()
			flip_direction()

func _on_AnimatedSprite_frame_changed():
	var effect_name = self.name + "_" + sprite.animation	
	print(effects.frames.has_animation(effect_name))
	if(sprite.frame == run_effect_at_frame && effects.frames.has_animation(effect_name)):
		effects.show()
		effects.set_frame(1)
		effects.play(effect_name)

func _on_Effects_animation_finished():
	effects.hide()
