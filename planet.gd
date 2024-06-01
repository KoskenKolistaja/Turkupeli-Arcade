extends StaticBody3D

var hp = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/ProgressBar.value = hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

	
	if hp <= 0:
		die()

func get_hit(damage):
	hp -= damage
	update_progress_bar()

func die():
	$MeshInstance3D.hide()
	$CollisionShape3D.disabled = true
	get_parent().game_over()

func update_progress_bar():
	$CanvasLayer/ProgressBar.value = hp
	$CanvasLayer/ProgressBar.show()
	$Timer.start()

func explode():
	hp -= 10
	update_progress_bar()

func collide():
	hp -= 1
	update_progress_bar()




func _on_timer_timeout():
	$CanvasLayer/ProgressBar.hide()
