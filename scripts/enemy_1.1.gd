extends "res://scripts/enemy_template.gd"

signal collide_player

func _ready() -> void:
	call_deferred("connect_to_player")
	
#warning-ignore:unused_argument
func _physics_process(delta : float) -> void:
	for child in raycast_group_collide_player.get_children():
		
		if child.is_colliding():
		
			emit_signal("collide_player")

func connect_to_player() -> void:
	#warning-ignore:return_value_discarded
	self.connect("collide_player", game.player, "on_collide_player")