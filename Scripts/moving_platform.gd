extends CharacterBody3D

@export var rotation_speed_deg := 30.0  # degrees per second

var previous_transform: Transform3D
var transform_delta: Transform3D = Transform3D.IDENTITY

func _ready():
	previous_transform = global_transform

func _physics_process(delta):
	# Store the transform BEFORE rotation
	previous_transform = global_transform

	# Apply rotation around the Y axis (in place)
	rotate_y(deg_to_rad(rotation_speed_deg * delta))

	# Calculate how the transform changed
	transform_delta = global_transform * previous_transform.affine_inverse()

func get_motion_delta() -> Transform3D:
	return transform_delta
