extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var target: Node3D  # Assign the player in the editor or at runtime
@export var detection_radius: float = 10.0

func _ready():
	add_to_group("enemies")
	if not target:
		target = get_tree().get_first_node_in_group("player")  # Optional fallback

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	if target:
		var distance = global_transform.origin.distance_to(target.global_transform.origin)
		if distance <= detection_radius:
			# Same movement logic
			var to_target = target.global_transform.origin - global_transform.origin
			to_target.y = 0
			var direction = to_target.normalized()

			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			# Player is out of range – idle
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
