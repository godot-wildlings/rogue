extends Node

const GRAVITY = 1600
const TERMINAL_VELOCITY = 660
const WORLD_LIMIT_Y = 250
const FLOOR = Vector2(0, -1)

enum CONTROL_TYPE { CONTROL_MOUSE, CONTROL_GAMEPAD }

#warning-ignore:unused_class_variable
var player : KinematicBody2D
#warning-ignore:unused_class_variable
var camera : Camera2D
#warning-ignore:unused_class_variable
var control_type : int = CONTROL_TYPE.CONTROL_MOUSE#CONTROL_TYPE.CONTROL_GAMEPAD#
#warning-ignore:unused_class_variable
var UI : CanvasLayer

func play_random_sfx(container : Node, random_pitch : bool = true):
	if is_instance_valid(container):
		var sfx_count : int = container.get_child_count()
		var rnd_sfx_idx : int = randi() % sfx_count
		var sfx_audio_player : AudioStreamPlayer2D = container.get_child(rnd_sfx_idx)
		if is_instance_valid(sfx_audio_player):
			if random_pitch:
				sfx_audio_player.pitch_scale = 1 + rand_range(-0.1, 0.1)
			if not sfx_audio_player.playing:
				sfx_audio_player.play()