extends KinematicBody2D

onready var raycast_group_walls = $Raycasts_walls
onready var raycast_group_corners = $Raycasts_corners
#warning-ignore:unused_class_variable
onready var raycast_group_collide_player = $Raycasts_collide_player

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

var vel : Vector2 = Vector2()


#stats and etc
var direc : int = -1


#warning-ignore:unused_argument
func hit(collision_data : KinematicCollision2D) -> void:
	_death()


func _death() -> void:
	queue_free()

func _physics_process(delta : float) -> void:
	
	vel.x = ACCEL
	
	position.x += (vel.x * delta) * direc
	
	for child in raycast_group_corners.get_children():
		if !child.is_colliding():
			position.y += ACCEL_AIR*delta
			print(str(position.y))
	
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