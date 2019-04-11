extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var raycast_group_walls = $Raycasts_walls
onready var raycast_group_corners = $Raycasts_corners
onready var raycast_group_collide_player = $Raycasts_collide_player

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

#stats and etc
var hit_points : int
var atk : int
var direc : int = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta : float) -> void:
	
	vel.x = ACCEL
	
	position.x += (vel.x * delta) * direc
	
#	for child in raycast_group_corners.get_children():
#
#		if !child.is_colliding():
#			if child.name == "check_corner_left" && !child.is_colliding():
#				direc = 1
#			elif child.name == "check_corner_right" && !child.is_colliding():
#				direc = -1
#			else:
#				pass
	
	for child in raycast_group_walls.get_children():
		
		if child.is_colliding():
			
			if child.name == "check_wall_left" && child.is_colliding():
				direc = 1
			elif child.name == "check_wall_right" && child.is_colliding():
				direc = -1
			else:
				pass