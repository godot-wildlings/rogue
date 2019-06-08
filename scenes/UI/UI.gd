extends CanvasLayer

var player_state_label : Label
var player_health_label : Label

func _ready() -> void:
	game.UI = self
	player_state_label = $h_box_container/player_state_label
	player_health_label = $h_box_container/player_health_label
	
func update_health_label(health : float) -> void:
	assert is_instance_valid(player_health_label)
	print("update_health")
	player_health_label.text = "HEALTH: " + str(health)