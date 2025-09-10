extends Node3D

@onready var player = $Player
@onready var camera_rig = $CameraRig
@onready var enemy = $Enemy

func _ready():
	camera_rig.target = player
