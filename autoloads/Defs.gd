extends Node

signal TipsUpdated(NewVal)
signal LifesUpdated(NewVal)
signal GameFinished(Points)

const SPAWN_POS			= Vector2(280, 184)
const ENTRY_POS			= Vector2(280, 154)
const QUEUE_HEAD_POS	= Vector2(288, 82)
const EXIT_POS			= Vector2(88, 184)

const MIN_SPAWN_TIME	= 10
const MAX_SPAWN_TIME	= 20

onready var Rand = RandomNumberGenerator.new()
onready var orders: Array = []

var Tips = 0 setget SetTips
var Lifes = 20 setget SetLifes

# Update speed and reset the rotation.
func SetTips(NewVal):
	print(NewVal)
	emit_signal("TipsUpdated", NewVal)

func SetLifes(NewVal):
	Lifes = clamp(NewVal, 0, 20)
	emit_signal("LifesUpdated", NewVal)
	if(Lifes == 0):
		emit_signal("GameFinished", Tips)

func _ready():
	set_process(false)
	randomize()
	emit_signal("LifesUpdated", Lifes)
	emit_signal("TipsUpdated", Tips)
