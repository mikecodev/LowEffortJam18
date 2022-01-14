extends Node2D

signal LeaveTip(Money)

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
export var MovablePath : NodePath

export var TargetPizzaSize = 0
export var TargetPizzaTopping = 0

var State = STATE.Entering;
var Movable
var ClientManager

# Output
var Tip = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	Movable = get_node(MovablePath)
	Movable.connect("PositionArrived", self, "OnPositionArrival")
	$PatienceTimer.connect("timeout", self, "MyPatienceIsGrowingSmaller")
	# ClientManager = get_node("/root/client_manager")
	# Movable.move_to(Defines.EnterPosition)

func AskForQueueSpace():	
	var Destination : Vector2
	var QueueEntered = false
	# bool QueueEntered = client_manager.EnterQueue(self, Destination)
	
	if QueueEntered:
		State.WalkingToQueue
		Movable.move_to(Destination)
	else:
		# TODO: Do we want pissed off clients that just enter the venue?
		Leave()
func WaitForATable():
	State = State.Queuing
	$PatienceTimer.start()
	# ClientManager.ArriveToDestination(self)
func WaitForFood():
	State = State.WaitingForFood
	# TODO: Either choose a random food now or this should be done outside this class or in the ready
	# TODO: ShowPizzaSign() Should show a bubble with the desired pizza
func LeaveAndTip():
	if State == State.FinishedEating:
		emit_signal("LeaveTip", Tip)
		Leave()
	else:
		printerr("Client Error: LeaveAndTip received but state wasn't finished eating. State = ", State)
func Leave():
	State = STATE.Leaving
	# Movable.move_to(Defines.ExitPosition)
func ExitStore():
	# TODO: Open the door, leave the store and QueueFree
	queue_free()
func OnFreeTable(Destination : Vector2):
	if State == State.Queuing:
		State = State.WalkingToTable
		Movable.move_to(Destination)
		return true
	else:
		printerr("Client Error: OnFreeTable received when the State wasn't queuing. State = ", State)
		return false
func OnPositionArrival():
	match State:
		State.Entering:
			AskForQueueSpace()
		State.WalkingToQueue:
			WaitForATable()
		State.WalkingToTable:
			WaitForFood()
		State.Leaving:
			ExitStore()
		_:
			printerr("Client Error: Unexpected OnPositionArrival received when state is ", State)
func DeliverFood(PizzaTopping, PizzaSize):
	if State == State.WaitingForFood:
		State = State.FinishedEating
		Tip = (((PizzaTopping == TargetPizzaTopping) + (TargetPizzaSize == TargetPizzaSize))*0.5)*Satisfaction
		# TODO: Penalty? Also when the customers decides to leave (check the timer)
	else:
		printerr("Client Error: DeliverFood received but the client wasn't waiting for food. The State was: ", State)
func MyPatienceIsGrowingSmaller():
	Satisfaction = clamp(Satisfaction - Patience, 0, 100)
	# TODO: Add the pissed off probability here (among other places). It has to be very small!
	if Satisfaction == 0:
		Leave()
	# TODO: Also add an object and call it here to update the patience visual effect
	
"""

Resultados:

#### Estado: Comiendo

Durante X tiempo, el cliente comerá y dependiendo de lo satisfecho que esté (tiempo que se tardó en atenderlo y pizza servida) dejará una propina y pasará al estado terminado de comer.

#### TerminadoDeComer

El cliente lanzará una señal con la propina que desee dejar y esperará a recibir la orden de la mesa de que ya puede marcharse. Esto es por si el cliente no está solo para no abandonar a su amigo. Sería muy descortés.

Al recibir un mensaje de la mesa de que todos han terminado de comer, pasará al estado abandonando.

#### CabreadoAMuerte

Al entrar en este estado, el cliente se dirigirá hacia un empleado y le golpeará, tirando la pizza al suelo si el empleado fuese cargando una pizza. Si el empleado no fuese cargando ninguna pizza, se aplicará un ministun.

#### Estado: Abandonando

El cliente se moverá hacia la salida y lanzará una señal para decir que ha abandonado el establecimiento (la mesa que toque recibirá esa señal y actuará en consecuencia).

## Mesas

- Tendrán un número indeterminado de sillas
- Tendrán entre 1 y Número de sillas clientes
"""
