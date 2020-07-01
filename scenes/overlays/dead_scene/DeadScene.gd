extends Control

onready var sprite = $MarginContainer/AnimatedSprite

func _ready():
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.			

func _on_Continue_pressed():
	Global.restart()

