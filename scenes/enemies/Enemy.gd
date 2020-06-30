extends Node2D

onready var body = $KinematicBody2D
onready var sprite = $KinematicBody2D/AnimatedSprite
onready var ray = $KinematicBody2D/RayCast2D
onready var flip_timer = $KinematicBody2D/FlipDirection
onready var body_collision = $KinematicBody2D/BodyCollision
onready var attack_area = $KinematicBody2D/AttackArea
onready var floor_check_ray = $KinematicBody2D/FloorCheck

signal hit

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite.play(current_animation)
	new_position.y += Global.level_gravity	

	if(sprite.animation != "Hurt"):	
		if(direction == DIRECTION.LEFT):
			new_position.x -= current_speed
		elif(direction == DIRECTION.RIGHT):
			new_position.x += current_speed
		
	if(ray.is_colliding()):		
		if(ray.get_collider().is_in_group("player")):			
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
	if(entered_body is KinematicBody2D && (entered_body as KinematicBody2D).is_in_group("player")):
		current_animation = "Attack"
	else:
		current_animation = "Walk"	
		flip_direction()

func _on_AttackArea_body_exited(exited_body):	
	current_animation = "Walk"
	if(exited_body is KinematicBody2D && (exited_body as KinematicBody2D).is_in_group("player")):
		flip_direction()


func _on_AttackArea_area_shape_entered(area_id, area, area_shape, self_shape):
	var owner = area.get_owner();
	
	if(owner.is_in_group("projectile")):
		current_animation = "Hurt"		
		
func _on_AnimatedSprite_animation_finished():
	if(sprite.animation == "Hurt"):
		current_animation = "Walk"
