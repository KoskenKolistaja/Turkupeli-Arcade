extends Area3D

var target
var initial_speed = 0.01
var max_speed = 0.02
var speed

var rotation_speed = 0.015

var homing = false

@export var explosion: PackedScene

@onready var forward_node = $forward_node

func _ready():
	speed = initial_speed


func _physics_process(delta):
	var forward_direction = (forward_node.global_position - self.global_position)
	var target_distance = Vector3.ZERO
	
	if is_instance_valid(target):
		target_distance = target.global_position - self.global_position
	
	#rotation
	
	if homing:
		
		speed += 0.001
		speed = clamp(max_speed,0,0.04)
		
		if target_distance.signed_angle_to(forward_direction,Vector3(0,0,1)) > 0:
			rotate(Vector3(0,0,1),-rotation_speed)
		else:
			rotate(Vector3(0,0,1),rotation_speed)
		
	else:
		speed *= 0.98
		$nozzle.emitting = false
		$flight.stop()
	
#	if not target:
#		homing = false
	
	global_position += forward_direction * speed




#func get_closest_target():
#	var target_list = get_tree().get_nodes_in_group("shootable")
#	var nearest_target
#
#	if target_list:
#		nearest_target = target_list[0]
#
#		for item in target_list:
#			if (item.global_position - self.global_position).length() < (nearest_target.global_position - self.global_position).length():
#				item = nearest_target
#
#
#
#	return nearest_target


func _on_body_entered(body):
	
	if body.has_method("explode"):
		body.explode()
	
	explode()

func get_hit(damage):
	explode()

func explode():
	spawn_explosion()
	queue_free()

func spawn_explosion():
	var explosion_instance = explosion.instantiate()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = self.global_position



func _on_timer_timeout():
	
	homing = true
	$nozzle.emitting = true
	$flight.play()
	$flight.pitch_scale += randf_range(-0.4,0.0)
	$CollisionShape3D.disabled = false


func _on_death_timer_timeout():
	if homing:
		explode()
	else:
		queue_free()
