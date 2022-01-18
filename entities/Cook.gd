extends Node2D

class_name Cook

const c_pizza = preload("res://entities/Pizza.tscn")

func _ready():
	if is_network_master():
		$Timer.start()

func add_pizza(order):
	var pos = Vector2(global_position.x, global_position.y -15)
	var path = Net.register_pizza(order, pos)
	var pizza = get_node(path)
	var gp = pizza.global_position
	$Tween.interpolate_property(pizza, "global_position",
		gp, Vector2(gp.x, gp.y + 30), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func check_orders():
	if is_network_master():
		var areas = $Area2D.get_overlapping_areas()
		if Defs.orders.size() > 0 and areas.size() == 0:
			var order = Defs.orders.pop_front()
			add_pizza(order)
