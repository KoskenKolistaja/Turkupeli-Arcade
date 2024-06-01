extends Node3D

@export var explosion_1: AudioStreamMP3
@export var explosion_2: AudioStreamMP3
@export var explosion_3: AudioStreamMP3

var explosion_sounds



# Called when the node enters the scene tree for the first time.
func _ready():
	$Sparks.emitting = true
	$Flash.emitting = true
	$Fire.emitting = true
	$Smoke.emitting = true
	
	explosion_sounds = [explosion_1,explosion_2,explosion_3]
	
	$sound.stream = explosion_sounds[randi_range(0,2)]
	
	$sound.pitch_scale += randf_range(-0.2,0.2)
	$sound.play()

func _physics_process(delta):
	$light.omni_range -= 0.1

func _on_timer_timeout():
	queue_free()
