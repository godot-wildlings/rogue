extends Enemy

export var speed : float = 100

var direction : int = -1

func _ready() -> void:
	._ready()

func _physics_process(delta : float) -> void:
	._physics_process(delta)
	if is_on_wall():
		direction *= -1
func _calculate_velocity(delta : float) -> void:
	velocity.x = speed * direction
	velocity.y = min(velocity.y + game.GRAVITY * delta, game.TERMINAL_VELOCITY)
