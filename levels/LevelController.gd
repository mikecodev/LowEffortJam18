extends Node2D

const c_person = preload("res://entities/Movable.tscn")
var entites = {}
var cameraTarget: String

func _ready():
	Net.connect("camera", self, "camera")
	Net.set_current_level(self)
	Net.rpc("world_ready")
	Net.register_person("Rido")

func add_person(pathname, scene):
	if not get_node(pathname):
		var p = c_person.instance()
		p.name = pathname
		add_child(p)
	
func camera(pathname):
	cameraTarget = pathname

func remove_entity(pathname):
	if get_child(pathname):
		remove_child(pathname)

func _process(_delta):
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input.length() > 0:
		Net.rpc_unreliable_id(1, "move_player", input)
