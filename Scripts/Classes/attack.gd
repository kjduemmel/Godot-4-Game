class_name Attack

var damage: float
var knockback_force: float

enum AttackType {
	NONE,
	PIERCE,
	SLASH,
	BLUDGEON
}
var type

enum Element {
	NONE,
	FIRE,
	ICE,
	LIGHTNING,
	POISON
}
var element: int

func _init(damage :float, knockback_force :float, type : AttackType, element : Element):
	self.damage = damage
	self.knockback_force = knockback_force
	self.element = element
