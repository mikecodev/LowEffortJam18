extends Node2D

class_name Client

signal LeaveTip(Money)
signal ImLeaving(Player)

enum STATE {
	Entering,
	WalkingToQueue
	Queuing,
	WalkingToTable,
	WaitingForFood,
	Eating,
	FinishedEating,
	PissedOff,
	Leaving
}



export(float, 0, 1) var Patience : float
export(int, 0, 100) var Satisfaction : int

export var TargetPizzaSize = 0
export var TargetPizzaTopping = 0

var State = STATE.Entering;
var Movable
var ClientManager

# tmp
var Destination

# Output
var Tip = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	var random = RandomNumberGenerator.new()
	random.randomize()
	var MovablePath = Net.register_person("NPC", Defs.SPAWN_POS, random.randi_range(1, 3))
	Movable = get_node(MovablePath)
	Movable.connect("path_done", self, "OnPositionArrival")
	$PatienceTimer.connect("timeout", self, "MyPatienceIsGrowingSmaller")
	ClientManager = get_node("/root/ClientManager")
	Movable.move_to(Defs.ENTRY_POS)
	Movable.play_bubble(Bubble.STATUS.upset)

func AskForQueueSpace():
	var QueueEntered = ClientManager.EnterQueue(self)
	if QueueEntered:
		State = STATE.WalkingToQueue
		print("moving to queue space")
		Movable.move_to(Destination)
	else:
		# TODO: Do we want pissed off clients that just enter the venue?
		Leave()
func WaitForATable():
	State = STATE.Queuing
	$PatienceTimer.start()
	ClientManager.ArrivedToQueueDestination()
func WaitForFood():
	State = STATE.WaitingForFood
	# TODO: Either choose a random food now or this should be done outside this class or in the ready
	# TODO: ShowPizzaSign() Should show a bubble with the desired pizza
func LeaveAndTip():
	if State == STATE.FinishedEating:
		emit_signal("LeaveTip", Tip)
		Leave()
	else:
		printerr("Client Error: LeaveAndTip received but state wasn't finished eating. State = ", State)
func Leave():
	State = STATE.Leaving
	print("moving to exit")
	Movable.move_to(Defs.EXIT_POS)
	emit_signal("ImLeaving", self)
func ExitStore():
	# TODO: Open the door, leave the store and QueueFree
	Net.rpc("remove_entity", Movable.get_path()) # movable deletion must be broadcasted
	queue_free() # Client exists in server only, dont need to broadcast deletion
func OnFreeTable(_Destination : Vector2):
	if State == STATE.Queuing:
		State = STATE.WalkingToTable
		print("moving to table")
		Movable.move_to(_Destination)
		return true
	else:
		printerr("Client Error: OnFreeTable received when the State wasn't queuing. State = ", State)
		return false
func OnPositionArrival():
	match State:
		STATE.Entering:
			AskForQueueSpace()
		STATE.WalkingToQueue:
			WaitForATable()
		STATE.WalkingToTable:
			WaitForFood()
		STATE.Leaving:
			ExitStore()
		STATE.Queuing:
			# Sometimes if somebody leaves the queue we move a step forward. Do nothing
			pass
		_:
			printerr("Client Error: Unexpected OnPositionArrival received when state is ", State)

func AdvancePositionInQueue():
	print("Move to Destination ", Destination)
	Movable.move_to(Destination)
	
func DeliverFood(PizzaTopping, PizzaSize):
	if State == STATE.WaitingForFood:
		State = STATE.FinishedEating
		Tip = (((PizzaTopping == TargetPizzaTopping) + (PizzaSize == TargetPizzaSize))*0.5)*Satisfaction
		# TODO: Penalty? Also when the customers decides to leave (check the timer)
	else:
		printerr("Client Error: DeliverFood received but the client wasn't waiting for food. The State was: ", State)
func MyPatienceIsGrowingSmaller():
	Satisfaction = int(clamp(Satisfaction - Patience, 0, 100))
	# TODO: Add the pissed off probability here (among other places). It has to be very small!
	if Satisfaction == 0:
		Leave()
	$PatienceTimer.stop()
	# TODO: Also add an object and call it here to update the patience visual effect

func GetMovable():
	return Movable
