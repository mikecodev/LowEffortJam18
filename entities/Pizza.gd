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

var sprite: AnimatedSprite
export(TYPE) var type
export(STATUS) var status

func area_enabled(yes):
	if yes:
		collision_layer = 2
	else: 
		collision_layer = 0

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
