extends Node2D

onready var animation_player:AnimationPlayer = $Platform/AnimationPlayer

func _ready():
	animation_player.play("LeftRight")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
