extends Node

const GRAVITY = 1600
const TERMINAL_VELOCITY = 660

enum CONTROL_TYPE { CONTROL_MOUSE, CONTROL_GAMEPAD }

#warning-ignore:unused_class_variable
var player : KinematicBody2D
#warning-ignore:unused_class_variable
var camera : Camera2D
#warning-ignore:unused_class_variable
var control_type : int = CONTROL_TYPE.CONTROL_MOUSE#CONTROL_TYPE.CONTROL_GAMEPAD#