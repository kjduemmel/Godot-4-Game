extends Area3D
class_name Hitbox

var attack_data

func _init(damage :float, knockback_force :float, type : Attack.AttackType = Attack.AttackType.NONE, element : Attack.Element = Attack.Element.NONE):
	attack_data = Attack.new(
	damage,
	knockback_force,
	type,
	element
)

func get_attack_data():
	return attack_data
