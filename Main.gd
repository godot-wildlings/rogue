"""
Main.gd will be responsible for assembling the UI, swapping levels and
	relaying signals between intanced nodes.

"""

extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	global.main = self
	global.main_scene = self
	
	var level1 = load("res://Levels/LevelTest.tscn")
	var newLevel = level1.instance()
	$Levels.add_child(newLevel)
	newLevel.start()
	
func _on_level_initialized():
	pass
