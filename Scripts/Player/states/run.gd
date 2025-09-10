extends PlayerState

func enter():
	# Optional: player.play_animation("run")
	pass

func physics_update(delta):
	var direction = player.get_direction()
	direction = direction.normalized()
	player.velocity = player.handle_walking(delta, direction, player.SPEED_GROUND_RUN)
	
	if direction.length() > 0.1:
		player.handle_looking(delta, direction)
	
	player.apply_platform_motion()
	
	player.move_and_slide()

func check_transitions():
	if not player.is_on_floor():
		return "FallState"
	if player.can_jump():
		return "JumpState"
	if not Input.is_action_pressed("Run"):
		return "WalkState"
	if !player.get_direction():
		return "IdleState"
