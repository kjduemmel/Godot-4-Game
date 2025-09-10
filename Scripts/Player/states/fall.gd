extends PlayerState

func enter():
	# Optional: player.play_animation("fall")
	pass

func physics_update(delta):
	player.velocity += player.get_gravity() * delta
	
	if player.lock_on_target:
		var to_target = player.lock_on_target.global_transform.origin - player.global_transform.origin
		var direction = Vector2(to_target.x, to_target.z)
		player.handle_looking(delta, direction)
	
	player.move_and_slide()

func check_transitions():
	if player.is_on_floor():
		return "LandingState"
