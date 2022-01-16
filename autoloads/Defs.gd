extends Node


const SPAWN_POS			= Vector2(280, 184)
const ENTRY_POS			= Vector2(280, 154)
const QUEUE_HEAD_POS	= Vector2(288, 82)
const EXIT_POS			= Vector2(88, 184)

const MIN_SPAWN_TIME	= 2
const MAX_SPAWN_TIME	= 5

onready var Rand = RandomNumberGenerator.new()

onready var orders: Array = []

func _ready():
	set_process(false)
	randomize()
