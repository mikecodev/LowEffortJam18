extends Node

var QEUEU_SIZE : int = 5
var QEUE_START : Vector2
var SPRITE_HEIGHT : int = 16


var FreeTables : Array = []
var QueuedClients : Array = []

func _ready():
	set_process(false)
func AddTable(Table):
	FreeTables.append(Table)
func RemoveTable(Table):
	var Pos = FreeTables.rfind(Table)
	if(Pos != -1):
		FreeTables.remove(Pos)
	return Pos
func EnterQueue(Client, Destination) -> bool:
	return false

func ArrivedToQueueDestination(Client):
	pass
