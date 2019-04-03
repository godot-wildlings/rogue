extends Area2D

# Declare member variables here. Examples:
signal picked_up(name)
export var key_name : String

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("start")
	
func start():
	if is_instance_valid(global.player) and global.player.has_method("_on_key_picked_up"):
		connect("picked_up", global.player, "_on_key_picked_up")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func die():
	call_deferred("queue_free")
	

func _on_Key_body_entered(body):
	if body == global.player:
		emit_signal("picked_up", key_name)
		die()
