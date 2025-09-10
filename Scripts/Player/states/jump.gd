extends PlayerState

func enter():
	player.velocity.y = player.JUMP_VELOCITY
	# Optional: player.play_animation("jump")
	pass

func physics_update(delta):
	player.velocity += player.get_gravity() * delta
	
	if player.lock_on_target:
		var to_target = player.lock_on_target.global_transform.origin - player.global_transform.origin
		var direction = Vector2(to_target.x, to_target.z)
		player.handle_looking(delta, direction)
	
	player.move_and_slide()

func check_transitions():
	if player.velocity.y < 0 and not player.is_on_floor():
		return "FallState"
	if player.is_on_floor():
		return "LandingState"
