extends KinematicBody2D

# Declare member variables here. Examples:
enum States { CAPTIVE, FREE }
var State = States.CAPTIVE
var velocity : Vector2 = Vector2.ZERO
var speed = 200.0
var shooting : bool = false
var blocked : bool = false
var leader : KinematicBody2D # probably global.player, but maybe someday we'll have other groups in formations.

var formation_position : Vector2

export (PackedScene) var bulletScene = load("res://Projectiles/Arrow/Arrow.tscn")


signal projectile_requested(projectile, vel, pos, rot)
signal follower_acquired(node)

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("start")
	
func start():
	connect("projectile_requested", global.current_level, "_on_projectile_requested")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State == States.FREE:
		velocity = aggregate_vectors()
		var collision = move_and_collide(velocity * speed * delta)
		if collision:
			pass


func aggregate_vectors():
	var returnVec : Vector2 = Vector2.ZERO
	var blocked = is_blocked()

	if blocked:
		returnVec += get_formation_vector()
	else:
		returnVec += get_follow_leader_vector()
	
	returnVec += get_avoid_allies_vector()
	
	return returnVec.normalized()

func get_formation_vector():
	# store an array of idealized positions (assuming the leader is facing Vector2.RIGHT)
	# find your position, based on your order in parent node
	# go toward that position.
	
	var returnVec = Vector2.ZERO
	var myPos = get_global_position()
	var leaderPos = leader.get_global_position()
	var mousePos = get_global_mouse_position()
	var offset = 45
	var formation_positions = [ Vector2(-1, -1)*offset, Vector2(-1, 1)*offset, Vector2(-2, -2)*offset, Vector2(-2, 2)*offset]
	var leader_targeting_angle = Vector2.RIGHT.angle_to_point(mousePos - leaderPos)
	var my_ideal_position = leaderPos + formation_positions[get_position_in_parent()].rotated(leader_targeting_angle)
	formation_position = my_ideal_position
	update()
	
	returnVec += (my_ideal_position - myPos).normalized()
	
	return returnVec
	

func _draw():
	draw_circle(to_local(formation_position), 15, Color.antiquewhite)
	
func get_follow_leader_vector():
	return (leader.get_global_position() - self.get_global_position()).normalized()

func get_avoid_allies_vector():
	var returnVec = Vector2.ZERO
	var avoid_distance = 45.0
	
	# do this for the player and each NPC ally following the player.
	var myPos = get_global_position()
	if myPos.distance_squared_to(leader.get_global_position()) < avoid_distance * avoid_distance:
		returnVec += (self.get_global_position() - leader.get_global_position()).normalized()
	
	for NPC in get_parent().get_children():
		# check for all sibling NPCs
		if NPC != self:
			if myPos.distance_squared_to(NPC.get_global_position()) < avoid_distance * avoid_distance:
				returnVec += (myPos - NPC.get_global_position()).normalized()
	if returnVec != Vector2.ZERO:
		return returnVec.normalized()
	else:
		return returnVec

func _on_cage_unlocked(rescuer):
	State = States.FREE
	leader = rescuer # most likely global.player
	
	if leader.has_method("_on_NPC_follower_acquired"):
		connect("follower_acquired", leader, "_on_NPC_follower_acquired")
		emit_signal("follower_acquired", self) # tell the player we're following them

func commence_shooting():
	shooting = true
	shoot()
	$ReloadTimer.start()
	
func stop_shooting():
	shooting = false
	$ReloadTimer.stop()
	
func _on_player_started_shooting():
	commence_shooting()
	
func _on_player_stopped_shooting():
	stop_shooting()

func is_blocked():
	var ray = $RayCast2D
	var rot = Vector2(1,0).angle_to_point(get_global_position()-get_global_mouse_position())
	var bulletVelocity = velocity + Vector2(global.options["arrow_speed"],0).rotated(rot)
	
	ray.set_cast_to(bulletVelocity / 5)
	if ray.is_colliding() == true:
		var obstacle = ray.get_collider()
		if obstacle:
			
			if obstacle.is_in_group("player") or obstacle.is_in_group("player_allies"):
				
				return true
	return false
	

func shoot():
	# check for a clean line of sight. Move if you don't have one. Then shoot.
	var rot = Vector2(1,0).angle_to_point(get_global_position()-get_global_mouse_position())
	var bulletVelocity = velocity + Vector2(global.options["arrow_speed"],0).rotated(rot)
	
	if not is_blocked():
		emit_signal("projectile_requested", bulletScene, bulletVelocity, get_global_position(), rad2deg(rot))
	
	

func _on_ReloadTimer_timeout():
	if shooting == true:
		shoot()
		$ReloadTimer.start()
	