extends Node3D

@export var follow_enabled := true
@export var target: Node3D
@export var offset_distance := -5.0
@export var vertical_offset := 0.0
@export var sensitivity := 0.003
@export var stick_sensitivity := 2.5

var rotation_x := 0.0  # vertical (pitch)
var rotation_y := 0.0  # horizontal (yaw)
var lock_on_target: Node3D = null
var current_distance := offset_distance
var focus_point : Vector3
const vertical_offset_lock_on := 2.5
const MIN_LOCKON_DISTANCE := -4.0  # Closest zoom in
const MAX_LOCKON_DISTANCE := -10.0  # Farthest zoom out
const MAX_ENEMY_DISTANCE := 20.0  # Max distance to consider for zoom scaling
const ZOOM_SPEED := 5.0
const ROTATION_SPEED := 50
const FOCUS_SPEED := 8.0



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	focus_point = Vector3(0, 0, 0)

func _process(delta: float) -> void:
	# Input for free camera look (only used when not locked on)
	if lock_on_target == null:
		var look_input_x := Input.get_action_strength("camera_right") - Input.get_action_strength("camera_left")
		var look_input_y := Input.get_action_strength("camera_down") - Input.get_action_strength("camera_up")

		rotation_y -= look_input_x * stick_sensitivity * delta
		rotation_x -= look_input_y * stick_sensitivity * delta
		rotation_x = clamp(rotation_x, deg_to_rad(-50), deg_to_rad(20))

	# Follow logic
	if follow_enabled and target:
		var player_pos = target.global_transform.origin

		# Zoom logic (for both free and lock-on modes)
		var target_distance := offset_distance
		if lock_on_target:
			var enemy_pos = lock_on_target.global_transform.origin
			var distance = player_pos.distance_to(enemy_pos)
			var t = clamp(distance / MAX_ENEMY_DISTANCE, 0.0, 1.0)
			target_distance = lerp(MIN_LOCKON_DISTANCE, MAX_LOCKON_DISTANCE, t)

		current_distance = lerp(current_distance, target_distance, ZOOM_SPEED * delta)

		if lock_on_target:
			var enemy_pos = lock_on_target.global_transform.origin

			# Desired direction from camera to midpoint between player and enemy
			var target_focus = (player_pos + enemy_pos) * 0.5
			var to_focus = target_focus - global_position
			to_focus = to_focus.normalized()

			# Extract desired yaw (horizontal) and pitch (vertical)
			var desired_yaw = atan2(-to_focus.x, -to_focus.z)
			var desired_pitch = asin(to_focus.y)

			# Smoothly rotate around the player
			var t := pow(ROTATION_SPEED * delta, 2)
			rotation_y = lerp_angle(rotation_y, desired_yaw, t)
			rotation_x = lerp(rotation_x, desired_pitch, t)

			# Position the camera based on smoothed yaw
			var angle_basis = Basis(Vector3.UP, rotation_y)
			var offset = angle_basis.z * current_distance  # Camera offset direction
			var above = Vector3.UP * vertical_offset_lock_on
			focus_point = focus_point.lerp(player_pos, FOCUS_SPEED * delta)
			global_position = focus_point - offset + above

			# Face the focus point
			look_at(focus_point, Vector3.UP)
		else:
			# Free camera: stays behind player based on look input
			focus_point = focus_point.lerp(player_pos, FOCUS_SPEED * delta)
			var back = -transform.basis.z
			var above = Vector3.UP * vertical_offset
			var behind = back * current_distance
			global_position = focus_point + behind + above
			# Apply final rotation
			rotation = Vector3(rotation_x, rotation_y, 0)



func _unhandled_input(event):
	if event is InputEventMouseMotion and lock_on_target == null:
		rotation_y -= event.relative.x * sensitivity
		rotation_x -= event.relative.y * sensitivity
		rotation_x = clamp(rotation_x, deg_to_rad(-50), deg_to_rad(20))
