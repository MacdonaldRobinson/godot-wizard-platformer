extends Control

onready var sprite = $MarginContainer/AnimatedSprite

func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):		
	print(Global.player_has_died)
	if Global.player_has_died:
		show()
		sprite.play("Death")
		get_tree().paused = true

func _on_Continue_pressed():	
	Global.restart()

