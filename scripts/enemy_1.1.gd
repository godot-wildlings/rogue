extends "res://scripts/enemy_template.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal collide_player

# Called when the node enters the scene tree for the first time.
func _ready():
	
	self.connect("collide_player", get_node("..//player"), "on_collide_player")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	
	for child in raycast_group_collide_player.get_children():
		
		if child.is_colliding():
		
			emit_signal("collide_player")