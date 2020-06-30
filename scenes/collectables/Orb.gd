extends Node2D

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_area_entered(area):		
	var owner = area.get_owner()	
	if owner != null && owner.is_in_group("player"):
		queue_free()
