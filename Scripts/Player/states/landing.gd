extends PlayerState

var landing_timer := 0.0
const LANDING_DURATION := 0.10  # Seconds
const LANDING_DECELERATION := 20.0  # Higher = faster stop

func enter():
	landing_timer = LANDING_DURATION
	player.jump_buffer_timer = 0.0  # Prevent jump buffering through landing
	# Optional: player.play_animation("land")

func physics_update(delta):
	landing_timer -= delta
	var direction = player.get_direction()
	player.velocity = player.handle_walking(delta, direction, player.SPEED_GROUND_WALK)
	
	if player.lock_on_target:
		var to_target = player.lock_on_target.global_transform.origin - player.global_transform.origin
		direction = Vector2(to_target.x, to_target.z)
	else:
		direction = player.get_direction()
	player.handle_looking(delta, direction)

	player.apply_platform_motion()

	player.move_and_slide()


func check_transitions():
	if landing_timer > 0:
		return null  # stay in LandingState
	if player.get_direction():
		if Input.is_action_pressed("Run"):
			return "RunState"
		else:
			return "WalkState"
	else:
		return "IdleState"
