extends Node


func _ready():
	get_tree().root.get_node("Main").OnStartServer()
