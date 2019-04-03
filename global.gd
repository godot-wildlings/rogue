"""
global is the autoload singleton which holds game options like game_speed and gravity.
It also provides node references for dependency injection:
	main, level, player, camera, etc.

"""


extends Node

var options = {
		"game_speed": 1.0,
		"aesthetic": "fantasy",
		"gravity": 9.8,
		"hold_to_shoot": true,
		"arrow_speed": 800.0
	}

enum states { INITIALIZING, PAUSED, PLAYING }
var state = states.INITIALIZING setget set_state, get_state

var player : Node2D
var main : Node
var main_scene: Node
var level : Node2D
var current_level: Node2D
var camera : Camera2D

var DEBUG: bool = false

func set_state(newState):
	state = newState

func get_state():
	return state