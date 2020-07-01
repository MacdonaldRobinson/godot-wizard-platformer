extends Control

onready var orb_number = $MarginContainer/VBoxContainer/TopBar/OrbsCollected/OrbNumber
onready var health_progress = $MarginContainer/VBoxContainer/TopBar/HealthBar/HealthProgress

onready var attack1_button = $MarginContainer/VBoxContainer/BottomBar/GridContainer/Attack1
onready var reset_timer = $ResetTimer

onready var say_box = $MarginContainer/VBoxContainer/BottomBar/SayBox

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	orb_number.text = str(Global.orbs_collected)
	health_progress.value = Global.player_health
		
#	if(Global.player != null && Global.player.sprite.animation == "Attack1"):
#		attack1_button.toggle_mode = true
#		attack1_button.pressed = true
#		attack1_button.emit_signal("pressed")		
	
func _on_SayBox_text_entered(new_text):	
	Global.player_saybox_text = new_text
	say_box.text = ""
	say_box.release_focus()
	
	
func _on_Attack1_pressed():
	print("Attack 1 pressed")		
	Global.raise_event("ui_attack1")
	
		
	reset_timer.start()

func _on_ResetTimer_timeout():
	print("Ran reset timer")
	attack1_button.pressed = false
	attack1_button.toggle_mode = false	
	reset_timer.stop()
