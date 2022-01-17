extends KinematicBody2D

class_name Movable

signal path_done
signal got_pizza(type)

enum TYPE {
	Player,
	Npc01,
	Npc02,
	Npc03
}

enum LOOK {
	up, down, left, right
}

export var speed = 250
export var friction = 0.01
export var acceleration = 0.1

onready var navigation: Navigation2D = get_parent().get_node("Navigation2D")
onready var debugpath: Line2D = get_parent().get_node("DebugPath")

onready var allow_animation_change_timer = Timer.new()
var allow_animation_change = true
var animation = "_"
var freezed = false
var velocity: Vector2 = Vector2.ZERO
var v_buffer: Vector2 = Vector2.ZERO
var path: PoolVector2Array
var skin = 0
var looking_at = LOOK.down
var pizza_carried
var bubble_status
onready var animated_sprite: AnimatedSprite = $asPlayer

func _ready():
	if is_network_master():
		allow_animation_change_timer.wait_time = .2
		allow_animation_change_timer.one_shot = true
		allow_animation_change_timer.connect("timeout", self, "reset_allow_animation_change")
		add_child(allow_animation_change_timer)
		update_play("idledown")
	else:
		set_process(false)
		set_physics_process(false)
	update_skin()

remotesync func play_bubble(status):
	if Net.is_from_server():
		bubble_status = status
		$Bubble.play_status(status)

func reset_allow_animation_change():
	allow_animation_change = true

remotesync func take_put():
	if Net.is_from_server():
		if pizza_carried:
			pizza_carried.area_enabled(true)
			var pos = put_pos()
			pizza_carried.global_position = pos
			pizza_carried = null
		else:
			var pizzas = $ActionArea.get_overlapping_areas()
			if pizzas.size() == 0:
				return
			var pizza = pizzas[0]
			pizza.area_enabled(false)
			pizza_carried = pizza
	
func put_pos():
	var g = global_position
	match looking_at:
		LOOK.left:
			return Vector2(g.x-10, g.y-10)
		LOOK.right:
			return Vector2(g.x+10, g.y-10)
		LOOK.up:
			return Vector2(g.x, g.y-20)
		LOOK.down:
			return Vector2(g.x, g.y+10)
	
remotesync func look_to(name):
	if Net.is_from_server():
		match name:
			LOOK.up:
				looking_at = LOOK.up
				update_play("idleup")
			LOOK.down:
				looking_at = LOOK.down
				update_play("idledown")
			LOOK.left:
				looking_at = LOOK.left
				update_play("idleleft")
			LOOK.right:
				looking_at = LOOK.right
				update_play("idleright")
	
func _physics_process(delta):
	if path and path.size() > 0:
		move_along_path()
	elif collision_mask == 0:
		collision_mask = 1
		collision_layer = 1
	
	velocity = Vector2.ZERO
	if v_buffer.length() > 0:
		velocity = lerp(velocity, Vector2(v_buffer[0], v_buffer[1]) * speed * delta, acceleration)
		if abs(velocity[0]) > 1:
			if velocity[0] > 0:
				update_play("right")
			else:
				update_play("left")
		else:
			if velocity[1] < 0:
				update_play("up")
			else:
				update_play("down")
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
		match animation:
			"right":
				update_play("idleright")
			"left":
				update_play("idleleft")
			"up":
				update_play("idleup")
			"down":
				update_play("idledown")
	velocity = move_and_slide(velocity)
	rpc_unreliable("puppet_move", transform.origin)
	if v_buffer != Vector2.ZERO:
		v_buffer = Vector2.ZERO
		
	if pizza_carried:
		pizza_carried.global_position = Vector2(global_position.x, global_position.y-20)

func move(direction):
	if is_network_master():
		v_buffer = direction * speed
	
func move_to(target_position: Vector2):
	collision_mask = 0
	collision_layer = 0
	path = navigation.get_simple_path(global_position, target_position)
	
func move_along_path():
	var start_point := global_position
	if debugpath:
		debugpath.points = path
	for _i in range(path.size()):
		var distance_to_next := start_point.distance_to(path[0])
		if distance_to_next > 1:
			v_buffer = (path[0] - start_point).normalized() * speed
			break
		path.remove(0)
	if path.size() == 0:
		emit_signal("path_done")
	
func freeze(time: float):
	if is_network_master():
		set_physics_process(false)
		freezed = true
		yield(get_tree().create_timer(time), "timeout")
		set_physics_process(true)
		freezed = false

func update_play(anim):
	if is_network_master():
		if animation != anim && allow_animation_change:
			allow_animation_change = false
			allow_animation_change_timer.start()
			if pizza_carried:
				anim += "_handsup"
			animation = anim
			rpc("play", anim)
		
remotesync func play(anim):
	if Net.is_from_server():
		animated_sprite.play(anim)
		match anim:
			"idledown": continue
			"idledown_handsup": continue
			"down": continue
			"down_handsup":
				looking_at = LOOK.down
			"idleup": continue
			"idleup_handsup": continue
			"up": continue
			"up_handsup":
				looking_at = LOOK.up
			"idleleft": continue
			"idleleft_handsup": continue
			"left": continue
			"left_handsup":
				looking_at = LOOK.left
			"idleright": continue
			"idleright_handsup": continue
			"right": continue
			"right_handsup":
				looking_at = LOOK.right

puppet func puppet_move(origin):
	if Net.is_from_server():
		transform.origin = origin
		
func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
		
# SKILLS
func skill(num: int, _pos: Vector2):
	if freezed: return
	match num:
		1:
			freeze(1)
			update_play("walk")
			Net.rpc("take_pizza")
			
func update_skin():
	match skin:
		TYPE.Player:
			animated_sprite = $asPlayer
		TYPE.Npc01:
			animated_sprite = $asNpc01
		TYPE.Npc02:
			animated_sprite = $asNpc02
		TYPE.Npc03:
			animated_sprite = $asNpc03
	animated_sprite.visible = true


func _on_pizza_near(area):
	if is_network_master():
		emit_signal("got_pizza", area)
		# print(TYPE.keys()[skin], " got_pizza ", Bubble.STATUS.keys()[area.pizza_type])

func take_pizza(pizza_body):
	if pizza_body.has_method("area_enabled"):
		pizza_body.area_enabled(false)
	$Tween.interpolate_property(pizza_body, "global_position",
		pizza_body.global_position, put_pos(), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
