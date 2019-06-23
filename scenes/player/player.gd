extends KinematicBody2D

onready var rotate : Node2D = $rotate
onready var arm : Sprite = $arm
onready var invincibility_timer : Timer = $invincibility_timer
onready var walking_dust_tscn : PackedScene = preload("res://scenes/player/animations/dust/running/running_dust.tscn")
onready var jumping_dust_tscn : PackedScene = preload("res://scenes/player/animations/dust/jumping/jumping_dust.tscn")
onready var landing_dust_tscn : PackedScene = preload("res://scenes/player/animations/dust/landing/landing_dust.tscn")
#warning-ignore:unused_class_variable
onready var sfx_container : Node = $sfx_container
onready var jump_sfx_container : Node = $sfx_container/jump_sfx


onready var effecst_anim : AnimationPlayer = $effects_anim
onready var stats : Node = $stats
export var debug : bool = false
export var max_health : float = 3

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
var is_invincible : bool = false
var is_firing : bool = false
#warning-ignore:unused_class_variable
var is_jumping : bool = false
#warning-ignore:unused_class_variable
var double_jump : bool = false
var anim_cur : String = ""
var anim_nxt : String = ""
var fsm : Node
var vel : Vector2 = Vector2()
var mouse_dir : Vector2 = Vector2()
var arm_dir_nxt : Vector2 = Vector2.RIGHT
var arm_dir_cur : Vector2 = Vector2.RIGHT
var dir_cur : int = 1
var fire_state : int
var camera_mode : int = 0
var fire_timer : float = 0
var current_health : float = max_health setget _set_current_health
var UI : CanvasLayer

signal on_health_change(new_health)

func _ready() -> void:
	assert is_instance_valid(stats)
	game.player = self
	#warning-ignore:return_value_discarded
	invincibility_timer.connect("timeout", self, "_on_invincibility_timer_timeout")
	# Initialize states machine
	fsm = preload( "res://scripts/fsm.gd" ).new(self, $states, $states/idle, debug)
	call_deferred("_deferred_ready")
	
func _deferred_ready() -> void:
	UI = game.UI
	#warning-ignore:return_value_discarded
	connect("on_health_change", UI, "update_health_label")
	self.current_health = max_health

func _physics_process(delta : float) -> void:
	if global_position.y > game.WORLD_LIMIT_Y:
		get_tree().quit()
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
		if $anim.has_animation(anim_cur):
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

func _death() -> void:
	get_tree().quit()

func _fire(delta : float) -> void:
	if not is_firing and \
			Input.is_action_pressed("btn_fire") and\
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
#				var n = preload( "res://scenes/player/bullet/muzzle_blast.tscn" ).instance()
#				n.position = arm.get_node( "fire_position" ).position + roffset
#				arm.add_child( n )
				# instance bullet
				arm.fire(stats.damage, get_parent(), roffset)
				# fire animation
				#arm.get_node( "armanim" ).play( "fire" )
				# next state
				fire_timer = FIRE_WAITTIME / stats.attack_speed
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
	
func running_dust() -> void:
	if fsm.state_cur != $states/run: return
	var dust : Object = walking_dust_tscn.instance()
	assert is_instance_valid(dust)
	dust.position = position + Vector2(-8 * (dir_cur * 1), 0)
	dust.scale.x = dir_cur
	get_parent().add_child(dust)

func landing_dust() -> void:
	var dust : Object = landing_dust_tscn.instance()
	dust.position = position + $rotate/player.position
	dust.scale.x = dir_cur
	get_parent().add_child(dust)

func jumping_dust() -> void:
	if fsm.state_cur != $states/jump and fsm.state_cur != $states/double_jump: return
	var dust : Object = jumping_dust_tscn.instance()
	dust.position = Vector2(position.x, position.y + dust.position.y)
	dust.scale.x = dir_cur
	get_parent().add_child(dust)

func jump() -> void:
	assert is_instance_valid(jump_sfx_container)
	game.play_random_sfx(jump_sfx_container)

func take_damage(damage : float) -> void:
	if current_health > 0 and not is_invincible:
		if debug: print("take_damage")
		self.current_health -= damage
		is_invincible = true
		assert effecst_anim.has_animation("take_damage")
		effecst_anim.play("take_damage")
		invincibility_timer.start()

func _set_current_health(new_health) -> void:
	if debug: print("new_health: " + str(new_health))
	if new_health <= 0:
		_death()
	else:
		current_health = new_health
		emit_signal("on_health_change", current_health)

func _on_invincibility_timer_timeout() -> void:
	is_invincible = false
	effecst_anim.stop(true)
	modulate.a = 1