extends Node


func _ready():
	Net.run_as_server()
	get_tree().root.get_node("Main").OnStartServer()
