extends Control



func _on_Button_pressed():
	Net.rpc("register_player", $CenterContainer/VBoxContainer/LineEdit.text)
