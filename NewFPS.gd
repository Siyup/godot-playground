extends KinematicBody

signal box_touched (direction, speed)

var speed
var default_move_speed = 10
var sprint_speed = default_move_speed * 2
var crouch_move_speed = 3
var crouch_speed = 20
var h_acceleration = 6
var air_acceleration = 1
var normal_acceleration = 6
var gravity = 20
var jump = 10
var full_contact = false

var damage = 100

var default_height = 1.5
var crouch_height = 0.5

var mouse_sensitivity = 0.03

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()


onready var head = $Head
onready var ground_check = $groundCheck
onready var pcap = $CollisionShape
onready var bonker = $headBonker
onready var aimcast = $Head/Camera/aimCast
onready var muzzle = $Head/gun/muzzle
onready var bullet = preload("res://Bullet.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x*mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func do_ray_cast_collision(): 
	var bullet = get_world().direct_space_state
	var collision = bullet.intersect_ray(muzzle.transform.origin, aimcast.get_collision_point())
	if collision:
		var target = collision.collider
		if target.is_in_group("enemy"):
			print('hit enemy')
			target.health -= damage

func _physics_process(delta):
	
	var head_bonked = false
	
	direction = Vector3()
	speed = default_move_speed
	
	full_contact = ground_check.is_colliding()
	
	if bonker.is_colliding():
		head_bonked = true
	
	# fire mechanics
	if Input.is_action_just_pressed("fire"):
		if aimcast.is_colliding():
			var bulletInstance = bullet.instance()
			print(bulletInstance)
			muzzle.add_child(bulletInstance)
			bulletInstance.look_at(aimcast.get_collision_point(), Vector3.UP)
			print(muzzle.get_child_count(), aimcast.get_collision_point())
			bulletInstance.shoot = true
	
	# jump mechanics
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		h_acceleration = air_acceleration
	elif is_on_floor() && full_contact:
		gravity_vec = -get_floor_normal() *  gravity
		h_acceleration = normal_acceleration
	else:
		gravity_vec = -get_floor_normal()
		h_acceleration = normal_acceleration
	
	if Input.is_action_pressed("crouch"):
		self.scale.y -= crouch_speed * delta
		speed = crouch_move_speed
	elif not head_bonked:
		self.scale.y += crouch_speed * delta
	self.scale.y = clamp(self.scale.y, crouch_height, default_height)
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() || full_contact):
		gravity_vec = Vector3.UP * jump
	
	# walk mechanics
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backwards"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	
	direction = direction.normalized()
	h_velocity = h_velocity.linear_interpolate(direction*speed, h_acceleration*delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	move_and_slide(movement, Vector3.UP)


func _on_Area_body_entered(body):
	if body.name == self.name:
		emit_signal("box_touched", direction, speed)
	pass # Replace with function body.
