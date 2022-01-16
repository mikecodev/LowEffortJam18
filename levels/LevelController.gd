extends Node2D

const c_person = preload("res://entities/Movable.tscn")
var entites = {}

func _ready():
	Net.set_current_level(self)
	if is_network_master() and not Net.is_local:
		ClientManager.Start()

func Start():
	Net.rpc("world_ready")
	if Net.is_local:
		ClientManager.Start()
	$CanvasLayer/HUD.visible = true

func add_person(pathname):
	if not get_node(pathname):
		var p = c_person.instance()
		p.name = pathname
		add_child(p)

func remove_entity(pathname):
	if get_child(pathname):
		remove_child(pathname)

func _process(_delta):
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input.length() > 0:
		Net.rpc_unreliable_id(1, "move_player", input)
	var action_take_put = Input.action_press("take_put")

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			Net.rpc_id(1, "take_put")
