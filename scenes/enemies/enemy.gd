extends KinematicBody2D

class_name Enemy

onready var area : Area2D = $area
onready var anim : AnimationPlayer = $anim

export var debug : bool = false
#warning-ignore:unused_class_variable
export var damage : float = 1.5
export var max_health : float = 5

var health : float = max_health setget _set_health
var velocity : Vector2 = Vector2.ZERO

signal on_take_damage(new_health)

func _ready() -> void:
	assert is_instance_valid(area)
	assert is_instance_valid(anim)
	assert anim.has_animation("take_damage")
	#warning-ignore:return_value_discarded
	if not is_connected("on_take_damage", self, "_on_take_damage"):
		connect("on_take_damage", self, "_on_take_damage")

func _physics_process(delta : float) -> void:
	velocity = Vector2.ZERO
	
	_calculate_velocity(delta)

	for body in area.get_overlapping_bodies():
		assert is_instance_valid(body)
		if body == game.player:
			assert body.has_method("take_damage")
			body.take_damage(damage)

	#warning-ignore:return_value_discarded
	move_and_slide(velocity, game.FLOOR)

#warning-ignore:unused_argument
func _calculate_velocity(delta : float) -> void:
	pass

func _death() -> void:
	queue_free()

func _set_health(new_health : float) -> void:
	if new_health <= 0:
		_death()
	else:
		health = new_health
		if debug: print("new health: " + str(health))

func take_damage(damage : float) -> void:
	if debug: print("take_damage : " + str(damage))
	if health > 0:
		self.health -= damage
		emit_signal("on_take_damage", self.health)

#warning-ignore:unused_argument
func _on_take_damage(new_health : float) -> void:
	anim.play("take_damage")