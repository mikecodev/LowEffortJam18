extends Node


const SPAWN_POS			= Vector2(88, 184)
const ENTRY_POS			= Vector2(88, 143)
const QUEUE_HEAD_POS	= Vector2(286, 84)
const EXIT_POS			= Vector2(286, 84)

const MIN_SPAWN_TIME	= 0
const MAX_SPAWN_TIME	= 0

func _ready():
	set_process(false)
