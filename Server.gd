extends Node


func _ready():
	Net.run_as_server()
	get_tree().change_scene("res://levels/MainScene.tscn")
