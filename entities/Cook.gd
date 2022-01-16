extends Node2D

class_name Cook

const c_pizza = preload("res://entities/Pizza.tscn")

remotesync func add_pizza(order):
	if Net.is_from_server():
		var pizza = c_pizza.instance()
		pizza.SetPizzaType(order)
		get_parent().add_child(pizza)
		pizza.global_position = Vector2(global_position.x, global_position.y + 12)

func check_orders():
	if is_network_master():
		var areas = $Area2D.get_overlapping_areas()
		if Defs.orders.size() > 0 and areas.size() == 0:
			var order = Defs.orders.pop_front()
			rpc("add_pizza", order)
