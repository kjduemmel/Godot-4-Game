extends PlayerState

func enter():
	pass#player.play_animation("walk")

func physics_update(delta):
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
	if not player.is_on_floor():
		return "FallState"
	if player.can_jump():
		return "JumpState"
	if !player.get_direction():
		return "IdleState"
	if Input.is_action_pressed("Run"):
		return "RunState"
