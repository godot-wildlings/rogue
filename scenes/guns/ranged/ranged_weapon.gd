extends Sprite

var bullet_tscn : PackedScene

func fire(parent : Node, offset : Vector2 = Vector2()) -> void:
	if bullet_tscn == null: return
	var b = bullet_tscn.instance()
	b.global_position = $fire_position.global_position + offset
	b.bullet_rotation = rotation
	parent.add_child(b)