extends CharacterBody3D

#var speed = Vector3.ZERO

const ACCELERATION = 0.01
const GRAVITY_STRENGTH = 0.003

var planet

var target

var target_acquired = false

var missile_loaded = true
var bullet_loaded = true

@onready var forward_node = $forward_node
@onready var nozzle = $nozzle
@onready var nozzle_light = $nozzle_light
@export var missile: PackedScene
@export var bullet: PackedScene

@export var player_id: int = 1

var target_list = []

func _ready():
	planet = get_tree().get_first_node_in_group("earth")
	$Reticle.modulate = Color(1,0,0)

func _physics_process(delta):
	
	
#	var thrust = get_input()
#	if thrust:
#		velocity += thrust * ACCELERATION
	nozzle.emitting = false
	
	if Input.is_action_pressed("p%s_up" % player_id):
		var forward_direction = forward_node.global_position - self.global_position
		velocity += forward_direction * ACCELERATION
		nozzle.emitting = true
		nozzle_light.omni_attenuation += 0.1
	else:
		nozzle_light.omni_attenuation -= 0.1

	
	if Input.is_action_just_pressed("p%s_up" % player_id):
		$flight_sound.play()
	if Input.is_action_just_released("p%s_up" % player_id):
		$flight_sound.stop()
	
	
	nozzle_light.omni_attenuation = clamp(nozzle_light.omni_attenuation,-1,1)
	
	
#	if Input.is_action_pressed("p%s_down" % player_id):
#		var forward_direction = forward_node.global_position - self.global_position
#		velocity += -forward_direction * ACCELERATION
	
	if Input.is_action_pressed("p%s_left" % player_id):
		rotate(Vector3(0,0,1),-0.05)
		$Camera3D.rotate(Vector3(0,0,1),0.05)
	if Input.is_action_pressed("p%s_right" % player_id):
		rotate(Vector3(0,0,1),0.05)
		$Camera3D.rotate(Vector3(0,0,1),-0.05)
	
	if Input.is_action_just_pressed("p%s_shoot2" % player_id):
		get_target()
		if target:
			$target_timer.start()
	
	if Input.is_action_pressed("p%s_shoot1" % player_id):
		if bullet_loaded:
			spawn_bullet()
	
	if Input.is_action_pressed("p%s_shoot2" % player_id) and missile_loaded:
		if target:
			if is_instance_valid(target):
				move_reticle(target)
				$Reticle.show()
			else:
				target_acquired = false
				$Reticle.hide()
		if not target_acquired:
			scale_reticle()
		
	if Input.is_action_just_released("p%s_shoot2" % player_id):
		if missile_loaded and target_acquired:
			_spawn_missile()
		target = null
		target_acquired = false
		$target_timer.stop()
		$Reticle.hide()
		$beep_sound.stop()
		if player_id == 1:
			$Reticle.modulate = Color(1,0,0)
		elif player_id == 2:
			$Reticle.modulate = Color(1,1,1)
		else:
			$Reticle.modulate = Color(0,0,1)
		$Reticle.scale.x = 0.05
		$Reticle.scale.y = 0.05
	
	
	
	#Gravity
	var gravity_direction = planet.global_position - self.global_position
	var gravity_multiplier = 1/gravity_direction.length()
	gravity_direction *= gravity_multiplier
	velocity += gravity_direction * GRAVITY_STRENGTH
	
	
	move_and_slide()

func spawn_bullet():
	print("juu")
	bullet_loaded = false
	
	var bullet_instance = bullet.instantiate()
	get_parent().add_child(bullet_instance)
	var forward_direction = forward_node.global_position - self.global_position
	bullet_instance.direction = (forward_node.global_position + Vector3(randf_range(-0.07,0.07),randf_range(-0.07,0.07),0) - self.global_position).normalized()
	bullet_instance.direction += velocity*0.0005
	bullet_instance.global_position = self.global_position + forward_direction*0.1
	$bullet_sound.play()
	$bullet_timer.start()


func scale_reticle():
	$Reticle.scale.x -= 0.001
	$Reticle.scale.y -= 0.001
	$Reticle.scale.x = clamp($Reticle.scale.x,0.01,0.1)
	$Reticle.scale.y = clamp($Reticle.scale.y,0.01,0.1)

func get_target():
	var nearest_target
	if target_list:
		nearest_target = get_nearest_target()
	if nearest_target:
		move_reticle(nearest_target)
		target = nearest_target


func get_nearest_target():
	var nearest_target = target_list[0]
	
	for item in target_list:
		if (item.global_position - self.global_position).length() < (nearest_target.global_position - self.global_position).length():
			nearest_target = item
	
	return nearest_target

func move_reticle(target):
	var camera = get_tree().get_first_node_in_group("camera")
	var reticle_position = camera.unproject_position(target.global_position)
	
	
	$Reticle.global_position = reticle_position



func _spawn_missile():
	var forward_direction = forward_node.global_position - self.global_position
	var missile_instance = missile.instantiate()
	get_parent().add_child(missile_instance)
	missile_instance.global_position = self.global_position + forward_direction * 0.07
	
	missile_instance.rotation = self.rotation
	missile_instance.target = target
	
	missile_loaded = false
	$Timer.start()

func explode():
	die()

func get_hit(damage):
	die()

func die():
	queue_free()
	get_parent().go_timer_start()


func get_input():
	var input_direction = Vector3.ZERO
	
	if Input.is_action_pressed("ui_up"):
		input_direction += Vector3(0,1,0)
	if Input.is_action_pressed("ui_down"):
		input_direction += Vector3(0,-1,0)
	if Input.is_action_pressed("ui_left"):
		input_direction += Vector3(1,0,0)
	if Input.is_action_pressed("ui_right"):
		input_direction += Vector3(-1,0,0)
	
	if input_direction:
		input_direction = input_direction.normalized()
	else:
		return
	
	return input_direction


func _on_timer_timeout():
	missile_loaded = true


func _on_area_3d_body_entered(body):
	if body.is_in_group("shootable"):
		target_list.append(body)


func _on_area_3d_body_exited(body):
	target_list.erase(body)


func _on_target_timer_timeout():
	target_acquired = true
	$beep_sound.play()
	$Reticle.modulate = Color(0,1,0)


func _on_bullet_timer_timeout():
	bullet_loaded = true
