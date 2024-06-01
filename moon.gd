extends CharacterBody3D

var d = 0.0
var speed = 0.1
var radius = 2

var hp = 100

func _ready():
	update_progress_bar()

func _physics_process(delta):
	
	d += delta
	
	global_position = Vector3(
		sin(d * speed) * radius,
		cos(d * speed) * radius,
		0)
	move_progress_bar()
	
	if hp <= 0:
		die()


func move_progress_bar():
	var camera = get_tree().get_first_node_in_group("camera")
	var progress_bar_position = camera.unproject_position(self.global_position)
	
	
	$CanvasLayer/ProgressBar.global_position = progress_bar_position + Vector2(-30,-20)


func get_hit(damage):
	hp -= damage*3
	update_progress_bar()

func die():
	get_parent().go_timer_start()
	queue_free()

func explode():
	hp -= 10
	update_progress_bar()

func _on_timer_timeout():
	$CanvasLayer/ProgressBar.hide()

func update_progress_bar():
	$CanvasLayer/ProgressBar.value = hp
	$CanvasLayer/ProgressBar.show()
	$Timer.start()
