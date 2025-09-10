extends CanvasLayer

@onready var lock_on_icon := get_node("LockOnIcon")
@onready var camera := get_viewport().get_camera_3d()

@export var player: Node3D  # Assign this via the editor

func _process(_delta):
	if player and player.lock_on_target:
		var target_pos = player.lock_on_target.global_transform.origin

		# Project world to screen
		var screen_pos = camera.unproject_position(target_pos)
		lock_on_icon.position = screen_pos

		# Scale to maintain size in 3D
		var distance = camera.global_transform.origin.distance_to(target_pos)
		var base_size = 8.0  # adjust depending on icon pixel size
		var scale_factor = base_size / distance
		lock_on_icon.scale = Vector2.ONE * scale_factor

		lock_on_icon.visible = true
	else:
		lock_on_icon.visible = false
