extends Control

onready var orb_number = $MarginContainer/HBoxContainer/OrbsCollected/OrbNumber
onready var health_progress = $MarginContainer/HBoxContainer/HealthBar/HealthProgress

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	orb_number.text = str(Global.orbs_collected)
	health_progress.value = Global.player_health
