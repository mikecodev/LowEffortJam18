extends Node

const CLIENT_SCENE = preload("res://entities/Client.tscn")

var QUEUE_SIZE : int = 5
var SPRITE_HEIGHT : int = 16


var FreeTables : Array = []
var QueuedClients : Array = []
var SpawnTimer

func _ready():
	set_process(false)
	SpawnTimer = Timer.new()
	SpawnTimer.one_shot = true
	add_child(SpawnTimer)
	SpawnTimer.connect("timeout", self, "OnClientSpawn")
func AddTable(Table):
	FreeTables.append(Table)
	Table.connect("FreeTable", self, "OnFreeTable")
func RemoveTable(Table):
	var Pos = FreeTables.rfind(Table)
	if(Pos != -1):
		FreeTables.remove(Pos)
	return Pos
# TODO: Perhaps get groups of people linked together when arriving, so instead of a client we receive a list of clients?
func EnterQueue(Client) -> bool:
	if QueuedClients.size() < QUEUE_SIZE:
		QueuedClients.push_back(Client)
		# El jodido vector2 no se pasa por referencia
		Client.Destination = Vector2(Defs.QUEUE_HEAD_POS.x, Defs.QUEUE_HEAD_POS.y + (QueuedClients.size()-1)*SPRITE_HEIGHT)
		return true
	return false
func ArrivedToQueueDestination():
	while(FreeTables.size() > 0 and QueuedClients.size() > 0 and QueuedClients[0].Queuing):
		var Table = FreeTables.pop_front()
		# TODO: So far we have no groups, so we are just sitting random people together. This should change to customers arriving together
		var NumClients = rand_range(1, min(Table.Seats.size(), QueuedClients.size()))
		var ClientsToSit = []
		for _n in range(NumClients):
			ClientsToSit.append(QueuedClients.pop_front())
		Table.Sit(ClientsToSit)
func OnFreeTable(Table):
	FreeTables.append(Table)
func OnClientSpawn():
	add_child(CLIENT_SCENE.instance())
	SpawnTimer.wait_time = rand_range(12, 20)
	SpawnTimer.start()
func Start():
	if is_network_master():
		SpawnTimer.start()
