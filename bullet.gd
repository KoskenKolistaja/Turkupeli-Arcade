extends Area3D

var direction = Vector3.ZERO
var speed = 0.03


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	global_position += direction*speed







func _on_body_entered(body):
	if body.has_method("get_hit"):
		body.get_hit(1)
	
	queue_free()


func _on_area_entered(area):
	if area.has_method("get_hit"):
		area.get_hit(1)


func _on_timer_timeout():
	queue_free()
