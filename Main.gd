extends Node


func _ready():
	Net.run_as_client()
	get_tree().change_scene("res://Menu.tscn")
