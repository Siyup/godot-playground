extends RigidBody

var shoot = false

const DAMAGE = 50
const SPEED = 10

func _ready():
	set_as_toplevel(true)
	pass # Replace with function body.

func _physics_process(delta):
	if shoot:
		apply_impulse(transform.basis.z, - transform.basis.z * SPEED)

func _on_Area_body_entered(body):
	if body.is_in_group("enemy"):
		body.health -= DAMAGE
	queue_free()
