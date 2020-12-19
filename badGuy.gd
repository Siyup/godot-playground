extends KinematicBody

var health = 200

var initialPos

onready var respawnTimer = $respawnTimer

func _ready():
	initialPos = self.transform.origin
	print(initialPos)
	pass # Replace with function body.

func _process(delta):
	if health <= 0:
		self.transform.origin = Vector3(-50, -50, -50)
		health = 200
		respawnTimer.start()	

func _on_respawnTimer_timeout():
	print('respawning')
	self.transform.origin = initialPos
	pass # Replace with function body.
