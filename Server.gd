extends Node

var main = preload("res://Main.tscn")

func _ready():
	Net.run_as_server()
	var m = main.instance()
	call_deferred("setstart", m)

func setstart(scene):
	get_tree().root.add_child(scene)
	scene.OnStartServer()
