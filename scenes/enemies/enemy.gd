extends KinematicBody2D

onready var direction_timer : Timer = $direction_timer
onready var area : Area2D = $area

export var speed : float = 100
export var damage : float = 1.5

var direction : int = -1

func _ready() -> void:
	assert is_instance_valid(direction_timer)
	assert is_instance_valid(area)
	#warning-ignore:return_value_discarded
	direction_timer.connect("timeout", self, "_on_direction_timer_timeout")
	#warning-ignore:return_value_discarded
#	area.connect("body_entered", self, "_on_area_body_entered")

#warning-ignore:unused_argument
func _process(delta : float) -> void:
	var velocity : Vector2 = Vector2.ZERO
	velocity.x = speed * direction
	velocity.y = min(velocity.y + game.GRAVITY * delta, game.TERMINAL_VELOCITY)

	for body in area.get_overlapping_bodies():
		assert is_instance_valid(body)
		if body == game.player:
			assert body.has_method("take_damage")
			body.take_damage(damage)

	#warning-ignore:return_value_discarded
	move_and_slide(velocity)

func _on_direction_timer_timeout() -> void:
	direction *= -1

func _on_area_body_entered(body : PhysicsBody2D) -> void:
	if is_instance_valid(body):
		if body == game.player:
			assert body.has_method("take_damage")
			body.take_damage(damage)