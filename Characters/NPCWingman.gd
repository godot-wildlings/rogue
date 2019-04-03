extends KinematicBody2D

# Declare member variables here. Examples:
enum States { CAPTIVE, FREE }
var State = States.CAPTIVE
var velocity : Vector2 = Vector2.ZERO
var speed = 200.0
var shooting : bool = false
export (PackedScene) var bulletScene = load("res://Projectiles/Arrow/Arrow.tscn")


signal projectile_requested(projectile, vel, pos, rot)
signal follower_acquired(node)

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("start")
	
func start():
	connect("projectile_requested", global.current_level, "_on_projectile_requested")
	connect("follower_acquired", global.player, "_on_NPC_follower_acquired")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State == States.FREE:
		velocity = aggregate_vectors()
		var collision = move_and_collide(velocity * speed * delta)
		if collision:
			pass


func aggregate_vectors():
	var returnVec : Vector2 = Vector2.ZERO
	returnVec += get_follow_player_vector()
	returnVec += get_avoid_allies_vector()
	return returnVec
	
func get_follow_player_vector():
	return (global.player.get_global_position() - self.get_global_position()).normalized()

func get_avoid_allies_vector():
	var returnVec = Vector2.ZERO
	var avoid_distance = 55.0
	
	# do this for the player and each NPC ally following the player.
	var myPos = get_global_position()
	if myPos.distance_squared_to(global.player.get_global_position()) < avoid_distance * avoid_distance:
		returnVec += (self.get_global_position() - global.player.get_global_position()).normalized()
	return returnVec

func _on_cage_unlocked():
	State = States.FREE
	emit_signal("follower_acquired", self) # tell the player we're following them

func commence_shooting():
	shooting = true
	$ReloadTimer.start()
	
func stop_shooting():
	shooting = false
	$ReloadTimer.stop()
	
func _on_player_started_shooting():
	commence_shooting()
	
func _on_player_stopped_shooting():
	stop_shooting()

func shoot():
	#look_at(get_global_mouse_position())
	
	var rot = Vector2(1,0).angle_to_point(get_global_position()-get_global_mouse_position())
	
	emit_signal("projectile_requested", bulletScene, velocity + Vector2(global.options["arrow_speed"],0).rotated(rot), get_global_position(), rad2deg(rot))
	

func _on_ReloadTimer_timeout():
	if shooting == true:
		shoot()
		$ReloadTimer.start()
	