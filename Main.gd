extends Node

onready var START_SCREEN_SCENE = preload("res://entities/GUI/StartScreen.tscn")
onready var WORLD_SCENE = preload("res://levels/MainScene.tscn")
var CurrentScene

func _ready():
	Net.connect("StartOnline", self, "OnStartOnline")
	Net.connect("StartLocal", self, "OnStartLocal")
	var StartScreen = START_SCREEN_SCENE.instance()
	add_child(StartScreen)
	CurrentScene = StartScreen.get_path()
	$Transition.SetBlack()
	$Transition.ShadeOut(4)

func OnStartOnline():
	$Transition.ShadeIn(2)
	yield($Transition, "AnimationFinished")
	get_node(CurrentScene).queue_free()
	var World = WORLD_SCENE.instance()
	add_child(World)
	CurrentScene = World.get_path()
	$Transition.ShadeOut(2)
	yield($Transition, "AnimationFinished")
	World.Start()

func OnStartLocal(World):
	$Transition.ShadeIn(2)
	yield($Transition, "AnimationFinished")
	get_node(CurrentScene).queue_free()
	CurrentScene = World.get_path()
	World.visible = true
	$Transition.ShadeOut(2)
	yield($Transition, "AnimationFinished")
	World.Start()
