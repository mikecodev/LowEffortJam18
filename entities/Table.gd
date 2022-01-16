extends StaticBody2D

signal AddPoints(Points)
signal FreeTable()

const SEAT_OFFSET = 32

# There might be one or more seats. Vector.Up, Vector.Down, Vector.Left, and Vector.Right
export(Array, Vector2) var Seats
var SittingClients = []
var ClientsEating = 0
var Tip = 0

func _ready():
	set_process(false)

func Sit(ClientsToSit):
	SittingClients = ClientsToSit
	var SeatIdx = 0
	for Client in ClientsToSit:
		Client.OnFreeTable(Seats[SeatIdx]*SEAT_OFFSET + global_position)
		ClientsEating += 1
		Client.connect("LeaveTip", self, "OnNpcSatisfied")

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
