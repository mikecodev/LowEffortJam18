extends Node2D

class_name Cook

const c_pizza = preload("res://entities/Pizza.tscn")

var served: bool = false

func add_pizza(order):
	served = true
	var pizza = c_pizza.instance()
	pizza.SetPizzaType(order)
	get_parent().add_child(pizza)
	pizza.global_position = Vector2(global_position.x, global_position.y + 12)

func check_orders():
	if Defs.orders.size() > 0 and !served:
		var order = Defs.orders.pop_front()
		add_pizza(order)
