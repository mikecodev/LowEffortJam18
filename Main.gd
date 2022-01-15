extends Node

onready var START_SCREEN = preload("res://entities/GUI/StartScreen.tscn")

var CurrentScene

func _ready():
	Net.connect("StartOnline", self, "OnStartOnline")
	Net.connect("StartLocal", self, "OnStartLocal")
	
	var StartScreen = START_SCREEN.instance()
	add_child(StartScreen)
	CurrentScene = StartScreen.get_path()

func OnStartOnline():
	print("Start online")

func OnStartLocal(World):
	print("Start local ", World.name)
