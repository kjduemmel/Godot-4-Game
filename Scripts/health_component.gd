extends Node3D
class_name HealthComponent
@export var MAX_HEALTH := 10.0
var health : float

func _ready():
	health = MAX_HEALTH



func damage(attack: Attack):
	health -= attack.attack_damage
	
	if health <= 0:
		var parent = get_parent()
		if parent.has_method("die"):
			parent.die()
