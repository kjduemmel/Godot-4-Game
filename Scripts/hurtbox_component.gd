extends Node3D
class_name HurtboxComponent  # Passive receiver

@export var health_component : HealthComponent
var recently_hit_by := []

func _ready():
	for area in get_children():
		if area is Area3D:
			area.area_entered.connect(_on_hurtbox_entered)

func _on_hurtbox_entered(hurtbox_area: Area3D):
	var hurtbox = hurtbox_area.get_parent()
	if hurtbox == null or hurtbox in recently_hit_by:
		return

	if hurtbox.has_method("get_attack_data"):
		var attack = hurtbox.get_attack_data()
		health_component.damage(attack)
		recently_hit_by.append(hurtbox)

func reset_hits():
	recently_hit_by.clear()
