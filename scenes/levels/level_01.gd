extends Node2D

func _ready() -> void:
	call_deferred("_set_camera_limits")

func _set_camera_limits() -> void:
	var pos_NW = find_node("camera_limit_NW")
	if pos_NW == null: return
	var pos_SE = find_node("camera_limit_SE")
	if pos_SE == null: return
	if game.camera == null: return
	game.camera.limit_left = pos_NW.position.x
	game.camera.limit_top = pos_NW.position.y
	game.camera.limit_right = pos_SE.position.x
	game.camera.limit_bottom = pos_SE.position.y