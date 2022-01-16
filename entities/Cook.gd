extends Node2D

class_name Cook

const c_pizza = preload("res://entities/Pizza.tscn")

func _ready():
	if is_network_master():
		$Timer.start()

func add_pizza(order):
	print("add pizza")
	var pos = Vector2(global_position.x, global_position.y + 12)
	Net.register_pizza(order, pos)

func check_orders():
	if is_network_master():
		var areas = $Area2D.get_overlapping_areas()
		if Defs.orders.size() > 0 and areas.size() == 0:
			var order = Defs.orders.pop_front()
			add_pizza(order)
