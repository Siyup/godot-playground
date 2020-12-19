extends KinematicBody


var isPushed = false
var power = 3
var point = Vector3()

func _process(delta):
	if point == transform.origin:
		isPushed = false
	if isPushed:
		var direction = point - transform.origin
		move_and_slide(direction)



func _on_NewFPS_box_touched(direction, speed):
	isPushed = true
	point = Vector3(direction)*power*speed
	pass # Replace with function body.
