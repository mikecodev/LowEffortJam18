extends Node


func _ready():
	Net.run_local()
	get_tree().change_scene("res://Menu.tscn")
