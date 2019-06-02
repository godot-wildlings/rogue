extends "res://scenes/guns/ranged/ranged_weapon.gd"

func _ready() -> void:
	bullet_tscn = preload("res://scenes/projectiles/arrow/arrow.tscn")

func check_fire() -> bool:
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_point($fire_position.global_position, 32, [get_parent()], 3 )
	if result.empty():
		return true
	elif result.size() == 1:
		if result[0].collider is Area2D:
			return true
	return false