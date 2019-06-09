extends KinematicBody2D

export var hit_wall_tscn : PackedScene = preload("res://scenes/projectiles/deku_nut/deku_nut_hit_wall.tscn")

onready var visibility_notifier : VisibilityNotifier2D = $visibility_notifier

var bullet_rotation : float = 0
var vel : int = 400
var is_colliding : bool = false
var dir : Vector2 = Vector2()
var damage : float

func _ready() -> void:
	dir = Vector2.RIGHT.rotated(bullet_rotation)
	$sprite.rotation = bullet_rotation
	#warning-ignore:return_value_discarded
	visibility_notifier.connect("screen_exited", self, "_on_visibility_notifier_screen_exited")

func _physics_process(delta : float) -> void:
	var coldata = move_and_collide(dir * vel * delta)
	if is_instance_valid(coldata):
		print(coldata)
		_collision(coldata)

func _collision(collision_data : KinematicCollision2D) -> void:
	if is_colliding: return
	is_colliding = true
	if collision_data.collider.has_method("take_damage"):
		collision_data.collider.take_damage(damage)
	else:
		var hit = hit_wall_tscn.instance()
		hit.rotation = (-collision_data.normal).angle()
		hit.position = collision_data.position
		get_parent().add_child(hit)
	queue_free()

func _on_visibility_notifier_screen_exited() -> void:
	queue_free()
