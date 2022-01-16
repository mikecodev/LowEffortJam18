extends StaticBody2D

signal AddPoints(Points)

onready var Seats		= [$PosUp.position, $PosDown.position, $PosLeft.position, $PosRight.position]
onready var Orientation	= [Movable.LOOK.down, Movable.LOOK.up, Movable.LOOK.right, Movable.LOOK.left]

var SittingClients = []
var ClientsEating = 0
var Tip = 0

func _ready():
	set_process(false)
	ClientManager.AddTable(self)

func Sit(ClientsToSit):
	SittingClients = ClientsToSit
	
	var Options = [0,1,2,3]
	
	for Client in ClientsToSit:
		var Idx = Options.pop_at(randi() % Options.size())
		Client.LookAtDir = Orientation[Idx]
		Client.OnFreeTable(Seats[Idx] + global_position)
		ClientsEating += 1
		Client.connect("LeaveTip", self, "OnNpcSatisfied")
		Client.connect("ImLeaving", self, "OnClientLeavingEarly")

func OnNpcSatisfied(NpcTip):
	Tip += NpcTip
	ClientsEating -= 1
	if(ClientsEating == 0):
		FreeTable()
func OnClientLeavingEarly():
	# TODO: DECREASE LIFES?
	ClientsEating -= 1
	if ClientsEating == 0:
		FreeTable()
	
func FreeTable():
	emit_signal("AddPoints", Tip)
	Tip = 0
	ClientsEating = 0
	for Client in SittingClients:
		Client.disconnect("LeaveTip", self, "OnNpcSatisfied")
		Client.disconnect("ImLeaving", self, "OnClientLeavingEarly")
		Client.Leave()
	SittingClients = []
	ClientManager.AddTable(self)
	print("Leaving table ", get_name())


