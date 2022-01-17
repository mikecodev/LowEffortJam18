extends AnimatedSprite

class_name Bubble

enum STATUS {
	empty,
	happy,
	unhappy,
	upset,
	disappointed,
	inlove,
	alert,
	veggie_pizza_small,
	veggie_pizza_large,
	pepperoni_pizza_small,
	pepperoni_pizza_large,
	beer
}

func _ready():
	set_process(false)


func play_status(status):
	if not status:
		status = STATUS.empty
	play(STATUS.keys()[status])
