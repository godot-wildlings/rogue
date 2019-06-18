extends Enemy

onready var direction_timer : Timer = $direction_timer

export var speed : float = 100

var direction : int = -1

func _ready() -> void:
	._ready()
	assert is_instance_valid(direction_timer)
	#warning-ignore:return_value_discarded
	direction_timer.connect("timeout", self, "_on_direction_timer_timeout")

func _process(delta : float) -> void:
	._process(delta)

func _calculate_velocity(delta : float) -> void:
	velocity.x = speed * direction
	velocity.y = min(velocity.y + game.GRAVITY * delta, game.TERMINAL_VELOCITY)

func _on_direction_timer_timeout() -> void:
	direction *= -1