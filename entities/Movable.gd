extends KinematicBody2D

export var gravity = Vector2.DOWN * 10
export var speed = 2
export var friction = 0.1
export var acceleration = 0.1
export var rot_speed = 0.85

var animation = "_"
var freezed = false
var velocity: Vector2 = Vector2.ZERO
var v_buffer: Vector2 = Vector2.ZERO

func _ready():
	if is_network_master():
		update_play("idle")
		$AnimationPlayer.playback_speed = speed
	else:
		set_process(false)
		set_physics_process(false)

func set_name(name):
	$Floating.set_text(name)
	
func _physics_process(delta):
	velocity = Vector2.ZERO
	if v_buffer.length() > 0:
		velocity = lerp(velocity, Vector2(v_buffer[0], v_buffer[1]) * speed, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
	velocity = move_and_slide(velocity)
	rpc_unreliable("puppet_move", transform.origin)
	if v_buffer != Vector2.ZERO:
		v_buffer = Vector2.ZERO

func move(direction):
	v_buffer = direction * speed
	
func freeze(time: float):
	if is_network_master():
		set_physics_process(false)
		freezed = true
		yield(get_tree().create_timer(time), "timeout")
		set_physics_process(true)
		freezed = false

func update_play(anim):
	if animation != anim:
		animation = anim
		rpc("play", anim)
		
remotesync func play(anim):
	if Net.is_from_server():
		$AnimationPlayer.play(anim)

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
