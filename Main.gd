extends Node3D

@export var asteroid: PackedScene
@export var enemy: PackedScene

var first_time = true
var score = 2024000
var dead = false

var current_time

func _ready():
	current_time = Time.get_ticks_msec()


func _physics_process(delta):
	if not dead:
		var to_be_added = Time.get_ticks_msec() - current_time
		score += to_be_added
		$score.text = str(score/1000)
		
		current_time = Time.get_ticks_msec()


func _on_timer_timeout():
	spawn_asteroid()


func spawn_asteroid() -> void:
	var asteroid_instance = asteroid.instantiate()
	add_child(asteroid_instance)
	
	if 0.5 > randf_range(0,1):
		asteroid_instance.global_position.y = randf_range(4,6)
	else:
		asteroid_instance.global_position.y = randf_range(-4,-6)
	
	if 0.5 > randf_range(0,1):
		asteroid_instance.global_position.x = randf_range(4,6)
	else:
		asteroid_instance.global_position.x = randf_range(-4,-6)
	
	
	
	asteroid_instance.velocity = Vector3(randf_range(0,10),randf_range(0,10),0)

func check_game_over():
	if not get_tree().get_nodes_in_group("player"):
		game_over()

func game_over():
	$game_over.show()
	dead = true
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer2.stop()
	$AudioStreamPlayer3.play(0.5)


func spawn_enemy() -> void:
	var enemy_instance = enemy.instantiate()
	add_child(enemy_instance)
	
	if 0.5 > randf_range(0,1):
		enemy_instance.global_position.y = randf_range(4,6)
	else:
		enemy_instance.global_position.y = randf_range(-4,-6)
	
	if 0.5 > randf_range(0,1):
		enemy_instance.global_position.x = randf_range(4,6)
	else:
		enemy_instance.global_position.x = randf_range(-4,-6)

func go_timer_start():
	$game_over_timer.start()

func _on_enemy_timer_timeout():
	spawn_enemy()


func _on_button_pressed():
	get_tree().reload_current_scene()


func _on_game_over_timer_timeout():
	check_game_over()


func _on_game_timer_timeout():
	if first_time:
		$enemy_timer.start()
		first_time = false
	$enemy_timer.wait_time -= 0.5
	$Timer.wait_time -= 0.5
	
	$enemy_timer.wait_time = clamp($enemy_timer.wait_time,0.5,100)
	$Timer.wait_time = clamp($Timer.wait_time,0.5,100)




func _on_audio_stream_player_finished():
	$AudioStreamPlayer2.play()


func _on_audio_stream_player_2_finished():
	$AudioStreamPlayer.play()
