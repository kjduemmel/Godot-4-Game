extends CharacterBody3D

@onready var camera := get_node("/root/Game/World3D/CameraRig")

#Speeds
@export var SPEED_GROUND_WALK = 8.0
@export var SPEED_GROUND_RUN = 12.0
@export var SPEED_GROUND_LAND = 6.5
@export var SPEED_GROUND_TARGET = 5.0
@export var ACCELERATION = 1.0
@export var DECELERATION = 0.5
@export var TURN_SPEED = 12.0
var TURN_SPEED_LAND = TURN_SPEED / 2.0

#Jumping
@export var JUMP_VELOCITY = 5.0
@export var COYOTE_TIME := 1  # seconds of leeway after falling
var coyote_timer := 0.0
@export var JUMP_BUFFER_TIME := 0.25  # seconds to buffer jump input
var jump_buffer_timer := 0.0
var current_platform: Node3D = null



#LockOn
var lock_on_target: Node3D = null
@export var LOCK_ON_RANGE = 20.0

var states = {}
var current_state: PlayerState

func _ready():
	states = {
		"IdleState": preload("res://Scripts/Player/states/idle.gd").new(),
		"WalkState": preload("res://Scripts/Player/states/walk.gd").new(),
		"RunState": preload("res://Scripts/Player/states/run.gd").new(),
		"JumpState": preload("res://Scripts/Player/states/jump.gd").new(),
		"FallState": preload("res://Scripts/Player/states/fall.gd").new(),
		"LandingState": preload("res://Scripts/Player/states/landing.gd").new(),
	}
	for state in states.values():
		state.player = self

	switch_state("IdleState")

func _process(delta):
	update_lock_on()
	current_state.update(delta)
	var next = current_state.check_transitions()
	if next and next != current_state.get_class():
		switch_state(next)

func _physics_process(delta):
	update_coyote_timer(delta)
	update_jump_buffer(delta)
	current_state.physics_update(delta)

func switch_state(name: String):
	if current_state:
		current_state.exit()
	current_state = states[name]
	current_state.enter()

func get_direction() -> Vector2:
	var input_dir := Input.get_vector("movement_left", "movement_right", "movement_up", "movement_down")
	if input_dir == Vector2.ZERO:
		return Vector2.ZERO

	if lock_on_target:
		var to_target = (lock_on_target.global_transform.origin - global_transform.origin)
		to_target.y = 0
		var forward = Vector2(to_target.x, to_target.z).normalized()
		var right = Vector2(-forward.y, forward.x)  # perpendicular right

		# Movement relative to the forward/right of the target line
		return (right * input_dir.x + forward * -input_dir.y)

	else:
		# Default camera-relative movement
		var cam_forward = -camera.global_transform.basis.z
		var cam_right = camera.global_transform.basis.x
		var forward_2d = Vector2(cam_forward.x, cam_forward.z).normalized()
		var right_2d = Vector2(cam_right.x, cam_right.z).normalized()
		return (right_2d * input_dir.x + forward_2d * -input_dir.y)

func handle_walking(_delta: float, direction: Vector2, moveSpeed: float) -> Vector3:
	if direction.angle_to(Vector2(velocity.x, velocity.z)) < 90:
		velocity.x = move_toward(velocity.x, direction.x * moveSpeed, ACCELERATION)
		velocity.z = move_toward(velocity.z, direction.y * moveSpeed, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION)
		velocity.z = move_toward(velocity.z, 0, DECELERATION)
			
	return velocity
	
func get_floor_velocity() -> Vector3:
	current_platform = null

	if not is_on_floor():
		return Vector3.ZERO

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_normal().dot(Vector3.UP) > 0.7:
			var collider = collision.get_collider()
			if collider:
				current_platform = collider
				if collider.has_method("get_linear_velocity"):
					return collider.get_linear_velocity()
	return Vector3.ZERO

func apply_platform_motion():
	get_floor_velocity()
	if current_platform and current_platform.has_method("get_motion_delta"):
		var delta_xform = current_platform.get_motion_delta()
		velocity = delta_xform.basis * velocity
		var rotation_delta = delta_xform.basis.get_euler()
		rotate_y(rotation_delta.y)
	
	
func handle_jumping(delta: float) -> Vector3:
	jump_buffer_timer -= delta
	
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
	
	if Input.is_action_just_pressed("movement_jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	
	if jump_buffer_timer>0 and coyote_timer>0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0
		
	return velocity

func handle_looking(delta: float, focus: Vector2):
	var current_rotation = rotation.y
	var direction = (focus).normalized()
	var target_rotation = atan2(-direction.x, -direction.y)
	rotation.y = lerp_angle(current_rotation, target_rotation, TURN_SPEED * delta * direction.length())

func find_nearest_enemy() -> Node3D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest = null
	var closest_dist = LOCK_ON_RANGE

	for enemy in enemies:
		if not enemy.is_inside_tree():
			continue
		var dist = global_transform.origin.distance_to(enemy.global_transform.origin)
		if dist < closest_dist:
			closest_dist = dist
			closest = enemy

	return closest
	
func update_coyote_timer(delta: float):
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

func update_jump_buffer(delta: float):
	if Input.is_action_just_pressed("movement_jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

func can_jump() -> bool:
	return jump_buffer_timer > 0.0 and coyote_timer > 0.0

func update_lock_on():
	if Input.is_action_pressed("lock_on"):
		if lock_on_target == null:
			lock_on_target = find_nearest_enemy()
		else:
			var distance = global_transform.origin.distance_to(lock_on_target.global_transform.origin)
			if distance > LOCK_ON_RANGE:
				lock_on_target = null
	else:
		lock_on_target = null
	camera.lock_on_target = lock_on_target
