extends Node

const CLIENT_SCENE = preload("res://entities/Client.tscn")

var QUEUE_SIZE : int = 5
var SPRITE_HEIGHT : int = 16


var FreeTables : Array = []
var QueuedClients : Array = []
var SpawnTimer
var CheckFreeTablesTimer

var ClientGroups = []

func _ready():
	for Group in range(0, 30):
		ClientGroups.append("ClientGroup" + str(Group))
	set_process(false)
	SpawnTimer = Timer.new()
	CheckFreeTablesTimer = Timer.new()
	
	SpawnTimer.one_shot = true
	add_child(SpawnTimer)
	add_child(CheckFreeTablesTimer)
	
	SpawnTimer.connect("timeout", self, "OnClientSpawn")
	CheckFreeTablesTimer.connect("timeout", self, "SendToTables")
	CheckFreeTablesTimer.start()
func AddTable(Table):
	FreeTables.append(Table)
func RemoveTable(Table):
	var Pos = FreeTables.rfind(Table)
	if(Pos != -1):
		FreeTables.remove(Pos)
	return Pos
# TODO: Perhaps get groups of people linked together when arriving, so instead of a client we receive a list of clients?
func EnterQueue(Client) -> bool:
	var NewClients = get_tree().get_nodes_in_group(Client.get_meta("GroupIdx"))
	if QueuedClients.size() + NewClients.size() < QUEUE_SIZE:
		for NewClient in NewClients:
			QueuedClients.push_back(NewClient)
			# El jodido vector2 no se pasa por referencia
			NewClient.Destination = Vector2(Defs.QUEUE_HEAD_POS.x, Defs.QUEUE_HEAD_POS.y + (QueuedClients.size()-1)*SPRITE_HEIGHT)
			NewClient.connect("ImLeaving", self, "OnPlayerLeaving")
		return true
	return false
	
func ArrivedToQueueDestination():
	SendToTables()
	
func SendToTables():
	while(FreeTables.size() > 0 and QueuedClients.size() > 0 and QueuedClients[0].State == Client.STATE.Queuing):
		var Table = FreeTables.pop_front()
		# TODO: So far we have no groups, so we are just sitting random people together. This should change to customers arriving together
		# var NumClients = Defs.Rand.randi_range(1, QueuedClients.size())
		var ClientsToSit = []
		var Client = QueuedClients.pop_front()
		var GroupIdx = Client.get_meta("GroupIdx")
		
		# Adding the leader first
		ClientsToSit.append(Client)
		while(QueuedClients.size() > 0 and QueuedClients[0].get_meta("GroupIdx") == GroupIdx):
			ClientsToSit.append(QueuedClients.pop_front())
		Table.Sit(ClientsToSit)
		RepositionClients()
		
func RepositionClients():
	# Reposition the remaining clients ahead
	for Idx in range(0, QueuedClients.size()):
		QueuedClients[Idx].Destination = Vector2(Defs.QUEUE_HEAD_POS.x, Defs.QUEUE_HEAD_POS.y + Idx * SPRITE_HEIGHT)
		QueuedClients[Idx].AdvancePositionInQueue()

func OnClientSpawn():
	var GroupSize = Defs.Rand.randi_range(1, 4)
	var ClientGroup = ClientGroups.pop_front()
	for _ClientIdx in range(0, GroupSize):
		var Client = CLIENT_SCENE.instance()
		if _ClientIdx == 0:
			Client.Lider = true
		Client.add_to_group(ClientGroup)
		Client.set_meta("GroupIdx", ClientGroup)
		add_child(Client)
	SpawnTimer.wait_time = rand_range(Defs.MIN_SPAWN_TIME, Defs.MAX_SPAWN_TIME)
	SpawnTimer.start()
func Start():
	if is_network_master():
		SpawnTimer.start()
func OnPlayerLeaving(Client):
	var Idx = QueuedClients.find(Client)
	if Idx != -1:
		for i in range(Idx+1, QueuedClients.size()):
			QueuedClients[i].Destination = Vector2(Defs.QUEUE_HEAD_POS.x, Defs.QUEUE_HEAD_POS.y + i*SPRITE_HEIGHT)
			QueuedClients[i].AdvancePositionInQueue()
		QueuedClients.erase(QueuedClients[Idx])
