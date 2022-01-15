extends Node

var QUEUE_SIZE : int = 5
var QEUE_START : Vector2
var SPRITE_HEIGHT : int = 16


var FreeTables : Array = []
var QueuedClients : Array = []

func _ready():
	set_process(false)
func AddTable(Table):
	FreeTables.append(Table)
	Table.connect("FreeTable", self, "OnFreeTable")
func RemoveTable(Table):
	var Pos = FreeTables.rfind(Table)
	if(Pos != -1):
		FreeTables.remove(Pos)
	return Pos

# TODO: Perhaps get groups of people linked together when arriving, so instead of a client we receive a list of clients?
func EnterQueue(Client, _Destination) -> bool:
	if QueuedClients.size() < QUEUE_SIZE:
		QueuedClients.push_back(Client)
		_Destination = Vector2(QEUE_START.x, QEUE_START.y + (QueuedClients.size()-1)*SPRITE_HEIGHT)
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
