extends AnimatedSprite

class_name Bubble

enum STATUS {
	empty,
	happy,
	unhappy,
	upset,
	disappointed,
	inlove,
	alert
}

func _ready():
	set_process(false)


func play_status(status):
	play(STATUS.keys()[status])
