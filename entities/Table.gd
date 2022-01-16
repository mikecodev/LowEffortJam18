extends StaticBody2D

signal AddPoints(Points)
signal FreeTable()

onready var Seats = [$PosUp.position, $PosDown.position, $PosLeft.position, $PosRight.position]
var SittingClients = []
var ClientsEating = 0
var Tip = 0

func _ready():
	set_process(false)
	ClientManager.AddTable(self)

func Sit(ClientsToSit):
	SittingClients = ClientsToSit
	var SeatIdx = 0
	for Client in ClientsToSit:
		Client.LookAtDir = Seats[SeatIdx]
		Client.OnFreeTable(Seats[SeatIdx] + global_position)
		ClientsEating += 1
		Client.connect("LeaveTip", self, "OnNpcSatisfied")
		Client.connect("ImLeaving", self, "OnClientLeavingEarly")
func OnNpcSatisfied(NpcTip):
	Tip += NpcTip
	ClientsEating -= 1
	if(ClientsEating == 0):
		FreeTable()

func FreeTable():
	emit_signal("AddPoints", Tip)
	Tip = 0
	ClientsEating = 0
	for Client in SittingClients:
		Client.Leave()
	SittingClients = 0
	emit_signal("FreeTable", self)

func OnClientLeavingEarly(Client):
	# TODO: DECREASE LIFES?
	ClientsEating -= 1
	if ClientsEating == 0:
		FreeTable()
	
