extends Area2D

class_name Pizza

signal PizzaEaten(Pizza)

var sprite: AnimatedSprite
var pizza_type

func area_enabled(yes):
	if yes:
		collision_layer = 2
	else: 
		collision_layer = 0

func _physics_process(_delta):
	if is_network_master():
		rpc_unreliable("update_pos", global_position)

puppet func update_pos(pos):
	global_position = pos

func SetPizzaType(type):
	match type:
		Bubble.STATUS.pepperoni_pizza_small:
			sprite = $PSmall
		Bubble.STATUS.pepperoni_pizza_large:
			sprite = $PLarge
		Bubble.STATUS.veggie_pizza_small:
			sprite = $VSmall
		Bubble.STATUS.veggie_pizza_large:
			sprite = $VLarge
		Bubble.STATUS.beer:
			sprite = $Beer
	pizza_type = type
	sprite.visible = true

func Consume():
	if sprite != null:
		sprite.playing = true

func FreePizza():
	emit_signal("PizzaEaten", self)
	Net.rpc("remove_pizza", get_path())

