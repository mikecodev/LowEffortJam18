extends Control

onready var Nickname = $Menu/Online/VBoxContainer/HBoxContainer/Nickname

func _ready():
	set_process(false)
	$Transition.SetBlack()
	$Transition.ShadeOut(4)
	
	var DestinationPos = $Menu.rect_position
	$Tween.interpolate_property($Menu, "rect_position", DestinationPos + Vector2.DOWN*200, DestinationPos, 3, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$Tween.start()






func _on_Online_button_up():
	if Nickname.text == "" or Nickname.text.length() < 3:
		Nickname.modulate = Color(1,0.6,0.6,1)
		return
	Net.run_as_server()
	Net.rpc("register_player", Nickname.text)


func _on_Local_button_up():
	Net.run_local()
	get_tree().change_scene("res://Menu.tscn")


func _on_Nickname_text_changed(new_text):
	Nickname.modulate = Color.white
