extends KinematicBody2D

onready var rotate : Node2D = $rotate
onready var arm : Sprite = $crossbow

export var debug : bool = false

enum FIRE_STATES { FIRE, WAIT }

const MAX_VEL_AIR : int = 100
const ACCEL_AIR : int = 5
const DECEL_AIR : int = 5
const MAX_VEL : int = 120
const ACCEL : int = 15
const DECEL : int = 25
const AIM_VEL : int = 10#5
const JUMP_VEL : int = 300
const JUMP_GRAVITY : int = 700
const JUMP_MAXTIME : float = 0.25
const JUMP_MARGIN : float = 0.1
const FIRE_WAITTIME : float = 0.25

var can_aim : bool = true
var is_firing : bool = false
var is_jumping : bool = false
var double_jump : bool = false
var is_on_platform : bool = false
var anim_cur : String = ""
var anim_nxt : String = ""
var fsm : Node
var vel_platform : Vector2 = Vector2()
var vel : Vector2 = Vector2()
var old_motion : Vector2 = Vector2()
var mouse_dir : Vector2 = Vector2()
var arm_dir_nxt : Vector2 = Vector2.RIGHT
var arm_dir_cur : Vector2 = Vector2.RIGHT
var dir_cur : int = 1
var camera_mode : int = 0
var fire_timer : int = 0
var fire_state : int

func _ready()-> void:
	game.player = self
	# Initialize states machine
	fsm = preload( "res://scripts/fsm.gd" ).new(self, $states, $states/idle, debug)
	
func _physics_process(delta : float) -> void:
	# update states machine
	fsm.run_machine(delta)
	# update weapon dir
	_aim_weapon(delta)
	# fire
	_fire(delta)
	# direction
	if vel.x > 0:
		dir_cur = 1
	elif vel.x < 0:
		dir_cur = -1
	# update animations
	if anim_nxt != anim_cur:
		anim_cur = anim_nxt
		$anim.play(anim_cur)


func _aim_weapon(delta : float) -> void:
	if can_aim:
		if game.control_type == game.CONTROL_TYPE.CONTROL_MOUSE:
			mouse_dir = get_global_mouse_position() - arm.global_position
		else:
			var gamepad_dir = Vector2( Input.get_joy_axis(0, JOY_ANALOG_RX), \
					Input.get_joy_axis(0, JOY_ANALOG_RY))
			if gamepad_dir.length_squared() > 0.1:
				mouse_dir = Vector2( Input.get_joy_axis(0, JOY_ANALOG_RX), \
					Input.get_joy_axis(0, JOY_ANALOG_RY)).normalized() * 200
			else:
				pass
	else:
		mouse_dir = Vector2(rotate.scale.x, 0)
	
	arm_dir_nxt = mouse_dir.normalized()
	arm_dir_cur = arm_dir_cur.linear_interpolate(arm_dir_nxt, AIM_VEL * delta)
	arm.rotation = arm_dir_cur.angle()
	if arm_dir_cur.x < 0:
		rotate.scale.x = -1
		arm.scale.y = -1
	else:
		rotate.scale.x = 1
		arm.scale.y = 1
	
	# set camera target
	if camera_mode == 0:
		#$camera_target.position = ( mouse_dir * 0.5 ).round()#( mouse_dir * 0.3 ).round()
		$camera_target.position = $camera_target.position.linear_interpolate( \
			(mouse_dir * Vector2(0.35, 0.5 )).round(), 5 * delta)
	else:
		$camera_target.position = $camera_target.position.linear_interpolate( \
				Vector2(180, mouse_dir.y * 0.5), 1 * delta)

func _fire(delta : float) -> void:
	#			fsm.state_cur != fsm.STATES.interact and \
#			fsm.state_cur != fsm.STATES.altar and \
#			fsm.state_cur != fsm.STATES.hit and \
#			fsm.state_nxt != fsm.STATES.hit and \
	if not is_firing and \
			Input.is_action_just_pressed("btn_fire") and\
			arm.check_fire():
		is_firing = true
		fire_state = FIRE_STATES.FIRE
	if is_firing:
		match fire_state:
			FIRE_STATES.FIRE:
				# random position
				var roffset = Vector2( \
					round( 0*rand_range( -1, 1 ) ), \
					round( rand_range( -3, 3 ) ) ) 
				# nozzle blast
#				var n = preload( "res://girl/bullet/muzzle_blast.tscn" ).instance()
#				n.position = arm.get_node( "fire_position" ).position + roffset
#				arm.add_child( n )
				# instance bullet
				arm.fire(get_parent(), roffset)
				# fire animation
				#arm.get_node( "armanim" ).play( "fire" )
				# next state
				fire_timer = FIRE_WAITTIME
				fire_state = FIRE_STATES.WAIT
				# sfx
				#$mplayer.mplay( preload( "res://sfx/player_shoot.wav" ) )
			FIRE_STATES.WAIT:
				fire_timer -= delta
				if fire_timer <= 0:
					is_firing = false

func check_ground() -> bool:
	if $down_left.is_colliding() or $down_right.is_colliding():
		return true
	return false