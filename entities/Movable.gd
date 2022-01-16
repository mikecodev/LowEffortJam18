extends KinematicBody2D

class_name Movable

signal path_done

enum TYPE {
	Player,
	Npc01,
	Npc02,
	Npc03
}

export var speed = 200
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

func play_bubble(status):
	$Bubble.play_status(status)

func reset_allow_animation_change():
	allow_animation_change = true

func set_name(name):
	$Floating.set_text(name)
	
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
	for i in range(path.size()):
		var x = path[0][0]
		var y = path[0][1]
		var px = int(x) - (int(x) % 16) + 8
		var py = int(y) - (int(y) % 16) + 8
		var distance_to_next := start_point.distance_to(Vector2(px, py))
		if distance_to_next > 1:
			v_buffer = (Vector2(px, py) - start_point).normalized() * speed
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
	if animation != anim && allow_animation_change:
		allow_animation_change = false
		allow_animation_change_timer.start()
		animation = anim
		rpc("play", anim)
		
remotesync func play(anim):
	if Net.is_from_server():
		animated_sprite.play(anim)

puppet func puppet_move(origin):
	if Net.is_from_server():
		transform.origin = origin
		
func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
		
# SKILLS
func skill(num: int, pos: Vector2):
	if freezed: return
	match num:
		1:
			freeze(1)
			update_play("walk")
			Net.rpc("take_pizza")
			
remotesync func SetType(type):
	if Net.is_from_server():
		match type:
			TYPE.Npc01:
				animated_sprite = $asNpc01
			TYPE.Npc02:
				animated_sprite = $asNpc02
			TYPE.Npc03:
				animated_sprite = $asNpc03
		animated_sprite.visible = true
		$asPlayer.visible = false
