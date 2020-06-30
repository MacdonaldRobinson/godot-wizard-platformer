extends Node2D


onready var particles:Particles2D = $Particles2D

signal enemy_hit
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Area2D_body_entered(body):
	if(body.is_in_group("enemy")):
		queue_free()
