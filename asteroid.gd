extends CharacterBody3D

var hp = 3

var planet
const GRAVITY_STRENGTH = 0.03

@export var explosion: PackedScene

func _ready():
	planet = get_tree().get_first_node_in_group("earth")
	velocity = Vector3(randf_range(-5,5),randf_range(-5,5),0)

func spawn_explosion():
	var explosion_instance = explosion.instantiate()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = self.global_position

func _physics_process(delta):
	
	
	
	
	var gravity_direction = planet.global_position - self.global_position
	var gravity_multiplier = 1/gravity_direction.length()
	gravity_direction *= gravity_multiplier
	velocity += gravity_direction * GRAVITY_STRENGTH
	
	
	move_and_collide(velocity*0.0005)
	
	if hp <= 0:
		explode()

func get_hit(damage):
	hp -= damage

func explode():
	spawn_explosion()
	queue_free()


func _on_area_3d_body_entered(body):
	if body.has_method("get_hit") and not body == self:
		body.get_hit(5)
		explode()
