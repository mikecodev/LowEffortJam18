extends Area2D

class_name Pizza

enum TYPE {
	PSmall,
	PLarge,
	MSmall,
	MLarge,
	VSmall,
	VLarge,
	Beer
}

enum STATUS {
	Ready,
	BeingServed,
	Served,
	Droped
}

var sprite: Sprite
export(TYPE) var type
export(STATUS) var status

func _ready():
	var random = RandomNumberGenerator.new()
	random.randomize()
	$Timer.wait_time = random.randi_range(5, 10)
	SetPizzaType(random.randi_range(0, 6))
	status = STATUS.Ready

func SetPizzaType(type):
	match type:
		TYPE.PSmall:
			sprite = $PSmall
		TYPE.PLarge:
			sprite = $PLarge
		TYPE.MSmall:
			sprite = $MSmall
		TYPE.MLarge:
			sprite = $MLarge
		TYPE.VSmall:
			sprite = $VSmall
		TYPE.VLarge:
			sprite = $VLarge
		TYPE.Beer:
			sprite = $Beer
	$PSmall.visible = false
	$PLarge.visible = false
	$MSmall.visible = false
	$MLarge.visible = false
	$VSmall.visible = false
	$VLarge.visible = false
	$Beer.visible = false
	sprite.visible = true

func _on_Timer_timeout():
	var random = RandomNumberGenerator.new()
	random.randomize()
	$Timer.wait_time = random.randi_range(5, 10)
	if status == STATUS.Ready:
		SetPizzaType(random.randi_range(0, 6))
