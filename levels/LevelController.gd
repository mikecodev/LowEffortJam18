extends Node2D

const c_person = preload("res://entities/Movable.tscn")
var entites = {}

func _ready():
	Net.set_current_level(self)
	if is_network_master() and not Net.is_local:
		var p = Net.register_person("Rido")
		move_demo(get_node(p))

func Start():
	Net.rpc("world_ready")
	if Net.is_local:
		# TODO: Put all the logic here
		var p = Net.register_person("Rido")
		move_demo(get_node(p))
	$CanvasLayer/HUD.visible = true

func move_demo(npc):
	while true:
		npc.move_to(Vector2(282, 62))
		yield(get_tree().create_timer(15), "timeout")
		npc.move_to(Vector2(10, 10))
		yield(get_tree().create_timer(15), "timeout")

func add_person(pathname, scene):
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
