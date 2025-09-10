extends PlayerState

func enter():
	pass  # e.g., player.play_animation("idle")

func physics_update(delta):
	player.velocity.x = move_toward(player.velocity.x, 0, player.DECELERATION * delta)
	player.velocity.z = move_toward(player.velocity.z, 0, player.DECELERATION * delta)
	
	if player.lock_on_target:
		var to_target = player.lock_on_target.global_transform.origin - player.global_transform.origin
		var direction = Vector2(to_target.x, to_target.z)
		player.handle_looking(delta, direction)
	
	player.apply_platform_motion()
	
	player.move_and_slide()

func check_transitions():
	if player.get_direction().length() > 0.1:
		return "WalkState"
	if not player.is_on_floor():
		return "FallState"
	if player.can_jump():
		return "JumpState"
