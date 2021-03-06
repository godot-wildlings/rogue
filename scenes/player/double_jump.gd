extends "res://scripts/state.gd"

var gravity_timer : float

func initialize(obj : Object) -> void:
	obj.double_jump = true
	obj.anim_nxt = "jump"
	obj.vel.y = -obj.JUMP_VEL
	gravity_timer = obj.JUMP_MAXTIME
#	obj.dust_jump()
	#obj.jump()

func run(obj : Object, delta : float) -> void:
	if gravity_timer > 0:
		gravity_timer -= delta
		# jump gravity
		obj.vel.y = min(obj.vel.y + obj.JUMP_GRAVITY * delta, game.TERMINAL_VELOCITY)
		if not Input.is_action_pressed("btn_jump"):
			gravity_timer = 0
	else:
		# normal gravity
		obj.vel.y = min(obj.vel.y + game.GRAVITY * delta, game.TERMINAL_VELOCITY)
	# move
	obj.vel = obj.move_and_slide(obj.vel)
	
	# player input
	var is_moving = false
	if Input.is_action_pressed("btn_left"):
		is_moving = true
		obj.vel.x = lerp(obj.vel.x, -obj.MAX_VEL_AIR, obj.ACCEL_AIR * delta)
	elif Input.is_action_pressed("btn_right"):
		is_moving = true
		obj.vel.x = lerp(obj.vel.x, obj.MAX_VEL_AIR, obj.ACCEL_AIR * delta)
	else:
		obj.vel.x = lerp(obj.vel.x, 0, obj.DECEL_AIR * delta)
		if abs(obj.vel.x) < 1:
			obj.vel.x = 0
		else:
			is_moving = true
	
	if obj.is_on_floor() and obj.check_ground():
		obj.is_jumping = false
		obj.double_jump = false
		obj.dust_land()
		if is_moving:
			obj.fsm.state_nxt = obj.fsm.STATES.run
		else:
			obj.fsm.state_nxt = obj.fsm.STATES.idle
	else:
		if obj.vel.y >= 0:
			# start falling
			obj.fsm.state_nxt = obj.fsm.STATES.fall