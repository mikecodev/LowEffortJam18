extends Node

signal camera(pathname)
signal remove_entity(pathname)
signal add_entity(pathname, scene)

const c_person = preload("res://entities/Movable.tscn")
var players = {}

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func run_as_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(29002, 512)
	get_tree().network_peer = peer

func run_as_client():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client("127.0.0.1", 29002)
	get_tree().network_peer = peer


# ----------
# CONNECTION

func _player_disconnected(id):
	if is_network_master():
		var p = players[id]
		if p.body:
			p.body.get_parent().remove_child(p.body)
		rpc("remove_entity", p.pathname)
		players.erase(id)

# Only called on clients, not server.
func _connected_ok():
	print("connected to server")

# Server kicked us
func _server_disconnected():
	print("server kicked us")

# Could not even connect to server
func _connected_fail():
	print("could not connect to server")


# ----
# RPCs client --> server

master func register_player(name):
	var id = get_id()
	var pi = c_person.instance()
	var pathname = "Player"+str(id)
	players[id] = {
		name = name,
		body = pi,
		pathname = pathname
	}
	pi.name = pathname
	pi.set_name(name)
	emit_signal("add_entity", pathname, pi)
	rpc_id(id, "load_world")
	
func register_person(name, id = 0):
	var pi = c_person.instance()
	if id == 0:
		id = pi.get_instance_id()
	var pathname = "NPC"+str(id)
	players[id] = {
		name = name,
		body = pi,
		pathname = pathname
	}
	pi.name = pathname
	pi.set_name(name)
	emit_signal("add_entity", pathname, pi)
	rpc_id(id, "load_world")
	
master func world_ready():
	var id = get_id()
	var p = players[id]
	rpc("instance_person", p.name, p.pathname)
	for pid in players:
		if pid != id:
			rpc_id(id, "instance_person", players[pid].name, players[pid].pathname)
	rpc_id(id, "camera_target", "/root/World/"+p.pathname)
	
master func move_player(input_v: Vector2):
	players[get_id()].body.move(input_v)

master func skill_input(num: int, direction: Vector2):
	players[get_id()].body.skill(num, direction)
	
	
# ----
# RPCs server --> client
	
puppet func load_world():
	if is_from_server():
		get_tree().change_scene("res://client/screens/World.tscn")
		rpc("world_ready")

puppet func instance_person(name: String, pathname, position: Vector2):
	if is_from_server():
		var pi = c_person.instance()
		pi.name = pathname
		pi.global_position = position
		emit_signal("add_entity", pathname, pi)
		
puppet func camera_target(pathname: String):
	if is_from_server():
		emit_signal("camera", pathname)
		
remotesync func remove_entity(pathname: String):
	if is_from_server():
		emit_signal("remove_entity", pathname)
	
# -----
# UTILS

func get_id():
	return get_tree().get_rpc_sender_id()

func is_from_server() -> bool:
	return get_tree().get_rpc_sender_id() == 1

