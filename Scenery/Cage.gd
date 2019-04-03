extends Area2D

# Declare member variables here. Examples:

export var key_name : String
signal unlocked(byWho)

# Called when the node enters the scene tree for the first time.
func _ready():
	for NPC in $CaptiveNPCs.get_children():
		connect("unlocked", NPC, "_on_cage_unlocked")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func die(byWho):
	emit_signal("unlocked", byWho)
	for NPC in $CaptiveNPCs.get_children():
		$CaptiveNPCs.remove_child(NPC)
		$"../FreeNPCs".add_child(NPC)
		NPC.set_global_position(get_global_position())
	call_deferred("queue_free")

func _on_Cage_body_entered(body):
	if body == global.player:
		
		if body.has_method("unlock"):
			var correct_key = false
			var keys_held = body.unlock()
			if keys_held.has(key_name):
				if keys_held[key_name] == true:
					correct_key = true
					$ding.play()
					yield(get_tree().create_timer(0.6), "timeout")
					die(body)
			if correct_key == false:
				$buzzer.play()
