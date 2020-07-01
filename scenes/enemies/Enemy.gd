extends Node2D

onready var body = $KinematicBody2D
onready var sprite = $KinematicBody2D/AnimatedSprite
onready var ray = $KinematicBody2D/RayCast2D
onready var flip_timer = $KinematicBody2D/FlipDirection
onready var body_collision = $KinematicBody2D/BodyCollision
onready var attack_area = $KinematicBody2D/AttackArea
onready var floor_check_ray = $KinematicBody2D/FloorCheck
onready var health_bar = $KinematicBody2D/BodyCollision/HealthBar
onready var death_timer = $KinematicBody2D/DeathTimer
onready var death_tween = $KinematicBody2D/DeathTween
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
func _physics_process(delta):
	sprite.play(current_animation)
	new_position.y += Global.level_gravity	
	
	if(health_bar.value == 0):
		sprite.play("Death")
		set_physics_process(false)
		body_collision.set_disabled(true)
		is_dead = true
		set_physics_process(false)

	if(sprite.animation != "Hurt"):	
		if(direction == DIRECTION.LEFT):
			new_position.x -= current_speed
		elif(direction == DIRECTION.RIGHT):
			new_position.x += current_speed
		
	if(ray.is_colliding()):		
		if(ray.get_collider().get_owner().is_in_group("player")):			
			if(!flip_timer.is_stopped()):
				flip_timer.stop()			
			current_speed = FOLLOW_SPEED			
	else:
		current_speed = WALK_SPEED
		if(flip_timer.is_stopped()):
			flip_timer.start()					
		
	
	new_position.x = lerp(new_position.x, 0, 0.1)
	new_position = body.move_and_slide(new_position, Vector2(0, -1))	
	
	if(!floor_check_ray.is_colliding()):
		flip_direction()


func flip_direction():
	flip_timer.stop()
	flip_timer.start()
	var offset = 60
		
	ray.cast_to.x *= -1		
	
	if(direction == DIRECTION.LEFT):		
		direction = DIRECTION.RIGHT
		sprite.flip_h = false
		body_collision.position.x -= offset
		ray.position.x -= offset		
		attack_area.position.x -= offset		
		floor_check_ray.position.x += offset
	else:
		direction = DIRECTION.LEFT
		sprite.flip_h = true
		body_collision.position.x += offset
		ray.position.x += offset		
		attack_area.position.x += offset
		floor_check_ray.position.x -= offset		

func _on_FlipDirection_timeout():
	flip_direction()

func _on_AttackArea_body_entered(entered_body):	 	
	var owner = entered_body.get_owner()
	if(owner != null && owner.is_in_group("player")):
		current_animation = "Attack"
	else:
		current_animation = "Walk"	
		flip_direction()

func _on_AttackArea_body_exited(exited_body):	
	current_animation = "Walk"
	var owner = exited_body.get_owner()
	if(owner!= null && owner.is_in_group("player")):
		flip_direction()


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
