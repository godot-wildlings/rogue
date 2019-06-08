extends Node2D

export var bullet_tscn : PackedScene

func fire(damage : float, parent : Node, offset : Vector2 = Vector2()) -> void:
	assert is_instance_valid(bullet_tscn)
	var b = bullet_tscn.instance()
	b.global_position = $fire_position.global_position + offset
	b.bullet_rotation = rotation
	b.damage = damage
	parent.add_child(b)
	
func check_fire() -> bool:
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_point($fire_position.global_position, 32, [get_parent()], 3 )
	if result.empty():
		return true
	elif result.size() == 1:
		if result[0].collider is Area2D:
			return true
	return false