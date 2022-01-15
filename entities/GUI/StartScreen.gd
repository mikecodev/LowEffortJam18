extends Control

onready var Nickname = $Menu/Online/VBoxContainer/HBoxContainer/Nickname

func _ready():
	set_process(false)
	var DestinationPos = $Menu.rect_position
	$Tween.interpolate_property($Menu, "rect_position", DestinationPos + Vector2.DOWN*200, DestinationPos, 3, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$Tween.start()
func _on_Online_button_up():
	if Nickname.text == "" or Nickname.text.length() < 3:
		Nickname.modulate = Color(1,0.6,0.6,1)
		return
	Net.run_as_client()
	yield(Net, "Connected")
	Net.rpc_id(1, "register_player", Nickname.text)
func _on_Local_button_up():
	Net.run_local()
	Net.rpc("register_player", "Player")
func _on_Nickname_text_changed(new_text):
	Nickname.modulate = Color.white
