extends Camera2D

const SCREEN_SIZE : Vector2 = Vector2(1280, 640)

func _ready() -> void:
	game.camera = self