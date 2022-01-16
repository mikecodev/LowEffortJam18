extends Node


const SPAWN_POS			= Vector2(88, 184)
const ENTRY_POS			= Vector2(88, 143)
const QUEUE_HEAD_POS	= Vector2(286, 84)
const EXIT_POS			= SPAWN_POS

const MIN_SPAWN_TIME	= 2
const MAX_SPAWN_TIME	= 5

onready var Rand = RandomNumberGenerator.new()

func _ready():
	set_process(false)
	randomize()
