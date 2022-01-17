extends Node

signal StartLocal()
signal StartOnline()
signal Connected()

const PLAYER_SPAWN = Vector2(70, 70)

const c_person = preload("res://entities/Movable.tscn")
const c_world = preload("res://levels/MainScene.tscn")
const c_pizza = preload("res://entities/Pizza.tscn")
var players = {}
var pizzas = {}
var world: Node2D

var is_local = false

func _ready():
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func run_local():
	var peer = NetworkedMultiplayerENet.new()
	peer.set_bind_ip("127.0.0.1")
	peer.create_server(29002, 512)
	get_tree().network_peer = peer
	is_local = true

func run_as_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(29002, 512)
	get_tree().network_peer = peer

func run_as_client():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client("galax.be", 29002)
	get_tree().network_peer = peer


func set_current_level(levelNode):
	world = levelNode
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
	emit_signal("Connected")

# Server kicked us
func _server_disconnected():
	print("server kicked us")

# Could not even connect to server
func _connected_fail():
	print("could not connect to server")


# ----
# RPCs client --> server

master func register_player(name):
	if is_local:
		var w = c_world.instance()
		add_child(w)
		w.visible = false
		world = w
		emit_signal("StartLocal", w)
		# var m = get_node("/root/Menu")
		# m.get_parent().remove_child(m)
	var id = get_id()
	register_person(name, PLAYER_SPAWN, 0, id)
	rpc_id(id, "load_world")
	
func register_pizza(type, pos: Vector2):
	if is_network_master():
		var pi = c_pizza.instance()
		var id = pi.get_instance_id()
		var pathname = "Pizza"+str(id)
		pizzas[id] = {
			"pathname": pathname,
			"type": type,
			"body": pi
		}
		pi.name = pathname
		pi.SetPizzaType(type)
		world.add_child(pi)
		pi.global_position = pos
		broadcast_world()
	
func register_person(name, pos = Vector2(5, 5), skin = 0, id = 0):
	if is_network_master():
		var pi = c_person.instance()
		if id == 0:
			id = pi.get_instance_id()
		var pathname = "NPC"+str(id)
		players[id] = {
			"name": name,
			"body": pi,
			"pathname": pathname,
			"skin": skin
		}
		pi.name = pathname
		pi.global_position = pos
		pi.skin = skin
		world.add_child(pi)
		broadcast_world()
		return pi.get_path()
	
func broadcast_world():
	for pid in players:
		var p = players[pid]
		rpc("instance_person", p.pathname, p.body.global_position, p.skin, p.body.bubble_status)
	for pizid in pizzas:
		var pizza = pizzas[pizid]
		rpc("instance_pizza", pizza.pathname, pizza.body.global_position, pizza.type)
	
master func move_player(input_v: Vector2):
	players[get_id()].body.move(input_v)

master func take_put():
	players[get_id()].body.rpc("take_put")
	
master func world_ready():
	broadcast_world()
	
# ----
# RPCs server --> client
	
remotesync func load_world():
	if is_local or is_network_master(): return
	if is_from_server():
		emit_signal("StartOnline")

remotesync func instance_person(pathname, position: Vector2, skin, bubble_status):
	if is_local or is_network_master(): return
	if is_from_server() and world:
		if not world.get_node(pathname):
			var pi = c_person.instance()
			pi.name = pathname
			pi.global_position = position
			pi.skin = skin
			pi.play_bubble(bubble_status)
			world.add_child(pi)
			
remotesync func instance_pizza(pathname, position: Vector2, type):
	if is_local or is_network_master(): return
	if is_from_server() and world:
		if not world.get_node(pathname):
			var pi = c_pizza.instance()
			pi.name = pathname
			pi.global_position = position
			pi.SetPizzaType(type)
			world.add_child(pi)
		
remotesync func remove_entity(pathname: String):
	if is_from_server():
		var node = get_node(pathname)
		if world and node:
			node.queue_free()
			if players.has(node.get_instance_id()):
				players.erase(node.get_instance_id())
				
remotesync func remove_pizza(pathname: String):
	if is_from_server():
		var node = get_node(pathname)
		if world and node:
			node.queue_free()
			if pizzas.has(node.get_instance_id()):
				pizzas.erase(node.get_instance_id())
	
# -----
# UTILS

func get_id():
	return get_tree().get_rpc_sender_id()

func is_from_server() -> bool:
	if is_local: return true
	return get_tree().get_rpc_sender_id() == 1

