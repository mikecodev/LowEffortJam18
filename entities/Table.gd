extends StaticBody2D

onready var Seats		= [$PosUp.position, $PosDown.position, $PosLeft.position, $PosRight.position]
onready var Orientation	= [Movable.LOOK.down, Movable.LOOK.up, Movable.LOOK.right, Movable.LOOK.left]

var SittingClients = []
var ClientsEating = 0
var Tip = 0
var Penalty = 0

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
func OnClientLeavingEarly(_Client):
	Penalty += 1
	ClientsEating -= 1
	if ClientsEating == 0:
		FreeTable()
	
func FreeTable():
	Defs.Lifes -= Penalty
	Defs.Tips += Tip
	Tip = 0
	Penalty = 0
	ClientsEating = 0
	var GroupIdx = SittingClients[0].get_meta("GroupIdx")
	for Client in SittingClients:
		Client.disconnect("LeaveTip", self, "OnNpcSatisfied")
		Client.disconnect("ImLeaving", self, "OnClientLeavingEarly")
		Client.Leave()
	ClientManager.ClientGroups.append(GroupIdx)
	SittingClients = []
	ClientManager.AddTable(self)


