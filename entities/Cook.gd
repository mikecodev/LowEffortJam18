extends Node2D

const c_pizza = preload("res://entities/Pizza.tscn")

func add_pizza(order):
	var pizza = c_pizza.instance()
	pizza.SetPizzaType(order)
	get_parent().add_child(pizza)
	pizza.global_position = Vector2(global_position.x, global_position.y + 12)

func check_orders():
	if Defs.orders.size() > 0:
		var order = Defs.orders.pop_front()
		add_pizza(order)
