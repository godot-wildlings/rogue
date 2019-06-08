extends CanvasLayer

var player_state_label : Label
var player_health_label : Label


func _ready() -> void:
	game.UI = self
	call_deferred("_deferred_ready")

func _deferred_ready() -> void:
	player_state_label = $h_box_container/player_state_label
	player_health_label = $h_box_container/player_health_label
	