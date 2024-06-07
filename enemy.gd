extends CharacterBody3D


@onready var action_list = []

@onready var forward_node = $forward_node

@export var explosion: PackedScene
@export var missile: PackedScene

const GRAVITY_STRENGTH = 0.01 
const RAY_LENGTH = 1000

var missile_cooldown = false

var random_negative = 1

var hp = 6

var planet

var forward_direction
var rotation_speed = 0.01
var acceleration = 0.01

var falling = false

func _ready():
	forward_direction = forward_node.global_position - self.global_position
	planet = get_tree().get_first_node_in_group("earth")
	
	if 0.5 < randf_range(0,1):
		random_negative = -1




func _physics_process(delta):
	
	if falling:
		var gravity_direction = planet.global_position - self.global_position
		var gravity_multiplier = 1/gravity_direction.length()
		gravity_direction *= gravity_multiplier
		velocity += gravity_direction * GRAVITY_STRENGTH
	
	if not action_list.back() and not falling:
		generate_action()
		print("juu?")
	
	if action_list.back():
		
		if typeof(action_list[0]) == TYPE_VECTOR3:
			move_to_point(action_list[0])
		else:
			shoot_missile()
	
	
	
	move_and_collide(velocity*0.005)
	
	if hp <= 0:
		die()

func generate_action():
	
	if not missile_cooldown and randf_range(0,1) < 0.5:
		action_list.append(get_closest_player())
	else:
		action_list.append(Vector3(random_negative*randf_range(0,3),randf_range(-3,3),0))
		var obstacle_state = check_obstacles()
		if obstacle_state:
			if obstacle_state.collider.is_in_group("earth"):
				remove_done_task()
				print("juu")




func shoot_missile():
	if not action_list[0]:
		return
	forward_direction = forward_node.global_position - self.global_position
	var coordinates = action_list[0].global_position
	
	if (self.global_position - coordinates).length() > 0.1:
		var target_distance = coordinates - self.global_position
		
		if target_distance.signed_angle_to(forward_direction,Vector3(0,0,1)) > 0.1:
			rotate(Vector3(0,0,1),-rotation_speed)
		elif target_distance.signed_angle_to(forward_direction,Vector3(0,0,1)) < -0.1:
			rotate(Vector3(0,0,1),rotation_speed)
		else:
			spawn_missile()
			remove_done_task()

func spawn_missile():
	var forward_direction = forward_node.global_position - self.global_position
	var missile_instance = missile.instantiate()
	get_parent().add_child(missile_instance)
	missile_instance.global_position = self.global_position + forward_direction * 0.07
	
	missile_instance.rotation = self.rotation
	missile_instance.target = action_list[0]
	missile_instance.initial_speed = 0.007
	missile_instance.max_speed = 0.01
	
	missile_cooldown = true
	$Timer.start()

func get_closest_player():
	var players = get_tree().get_nodes_in_group("player")
	var nearest_target
	if players:
		nearest_target = players[0]
		
		for item in players:
			if (item.global_position + self.global_position).length() < (nearest_target.global_position + self.global_position).length():
				nearest_target = item
	
	return nearest_target


func check_obstacles():
	var space_state = get_world_3d().direct_space_state
	var origin = self.global_position + forward_direction*0.1
	var action_list_0 = action_list[0]
	var end
	if typeof(action_list[0]) == TYPE_VECTOR3:
		end = origin + action_list[0] * RAY_LENGTH
	else:
		return
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = false
	var result = space_state.intersect_ray(query)
	return result


func get_hit(damage):
	hp -= damage
	
	if hp < 4:
		set_falling()


func move_to_point(coordinates):
	forward_direction = forward_node.global_position - self.global_position
	
	if (self.global_position - coordinates).length() > 0.1:
		var target_distance = coordinates - self.global_position
		
		if target_distance.signed_angle_to(forward_direction,Vector3(0,0,1)) > 0.1:
			rotate(Vector3(0,0,1),-rotation_speed)
		elif target_distance.signed_angle_to(forward_direction,Vector3(0,0,1)) < -0.1:
			rotate(Vector3(0,0,1),rotation_speed)
		else:
			thrust()
	else:
		$nozzle.emitting = false
		velocity = Vector3.ZERO
		remove_done_task()

func thrust():
	velocity = forward_direction.normalized()
	$nozzle.emitting = true



func explode():
	hp -= 4
	if falling:
		die()
	set_falling()


func set_falling():
	falling = true
	action_list.clear()
	$nozzle.emitting = false

func spawn_explosion():
	var explosion_instance = explosion.instantiate()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = self.global_position

func die():
	spawn_explosion()
	queue_free()

func shoot_towards():
	pass


func remove_done_task():
	action_list.remove_at(0)



func _on_area_3d_body_entered(body):
	if body.is_in_group("planet"):
		spawn_explosion()
		body.get_hit(1)
		queue_free()


func _on_timer_timeout():
	missile_cooldown = false
