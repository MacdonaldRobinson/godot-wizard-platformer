extends Control

onready var orb_number = $MarginContainer/VBoxContainer/TopBar/OrbsCollected/OrbNumber
onready var health_progress = $MarginContainer/VBoxContainer/TopBar/HealthBar/HealthProgress

onready var attack1_button = $MarginContainer/VBoxContainer/BottomBar/GridContainer/Attack1
onready var reset_timer = $ResetTimer

onready var say_box = $MarginContainer/VBoxContainer/BottomBar/SayBox

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var is_left_button_down = false
var is_right_button_down = false
var is_up_button_down = false
var is_down_button_down = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	orb_number.text = str(Global.get_store_item("orb"))
	health_progress.value = Global.player_health
	
	if(is_left_button_down):
		Global.raise_event("ui_left")
		
	if(is_right_button_down):
		Global.raise_event("ui_right")

	if(is_up_button_down):
		Global.raise_event("ui_up")	
		
	if(is_down_button_down):
		Global.raise_event("ui_dowm")	
	
	
func _on_SayBox_text_entered(new_text):	
	Global.player_saybox_text = new_text
	say_box.text = ""
	say_box.release_focus()
	
	
func _on_ResetTimer_timeout():
	attack1_button.pressed = false
	attack1_button.toggle_mode = false	
	reset_timer.stop()


func _on_SayBox_focus_entered():
	OS.show_virtual_keyboard(Global.player_saybox_text)


func _on_SayBox_focus_exited():
	OS.hide_virtual_keyboard()


func _on_Attack1_pressed():
	Global.raise_event("ui_attack1")
	reset_timer.start()	


func _on_Left_button_down():
	is_left_button_down = true


func _on_Up_button_down():
	is_up_button_down = true


func _on_Down_button_down():
	is_down_button_down = true


func _on_Right_button_down():
	is_right_button_down = true


func _on_Right_button_up():
	is_right_button_down = false


func _on_Down_button_up():
	is_down_button_down = false


func _on_Up_button_up():
	is_up_button_down = false


func _on_Left_button_up():
	is_left_button_down = false
