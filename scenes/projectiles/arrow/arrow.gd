extends KinematicBody2D

var bullet_rotation : float = 0
var vel : int = 400
var is_colliding : bool = false
var dir : Vector2 = Vector2()

func _ready() -> void:
	dir = Vector2.RIGHT.rotated(bullet_rotation)
	$sprite.rotation = bullet_rotation

func _physics_process(delta : float) -> void:
	var coldata = move_and_collide(dir * vel * delta)
	if is_instance_valid(coldata):
		_collision(coldata)
		
func _collision(cdata : KinematicCollision2D) -> void:
	if is_colliding: return
	is_colliding = true
	if cdata.collider.has_method("hit"):
		cdata.collider.hit(cdata)
	else:
		# ToDo: spawn "hit wall tscn" (particle effects)
		pass
		#var h = hit_wall_scn.instance()
		#h.rotation = ( -cdata.normal ).angle()
		#h.position = cdata.position
		#get_parent().add_child( h )
	queue_free()

func _on_visible_screen_exited() -> void:
	queue_free()
