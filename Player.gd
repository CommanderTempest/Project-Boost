extends RigidBody3D

# How much vertical force to apply when moving/holding spacebar
@export_range(1000.0, 2000.0) var thrust = 1000.0;
# How much rotational force to apply when rotating/holding A or D
@export var rotationalForce = 200.0

# $ = nodepath
@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_boost_particles: GPUParticles3D = $RightBoostParticles
@onready var left_boost_particles: GPUParticles3D = $LeftBoostParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

var is_transitioning: bool = false
var finishInterval: float = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if (rocket_audio.playing == false):
			rocket_audio.play()
	else:
		if (rocket_audio.playing):
			rocket_audio.stop()
			booster_particles.emitting = false
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, rotationalForce * delta))
		right_boost_particles.emitting = true
	else:
		right_boost_particles.emitting = false
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -rotationalForce * delta))
		left_boost_particles.emitting = true
	else:
		left_boost_particles.emitting = false
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_body_entered(body: Node) -> void:
	if (is_transitioning == false):
		if (body.is_in_group("Floor")):
			crash_sequence()
		elif (body.is_in_group("Goal")):
			success_sequence(body.file_path)
	
func crash_sequence() -> void:
	explosion_audio.play()
	explosion_particles.emitting = true
	is_transitioning = true
	set_process(false)
	var tween = create_tween()
	tween.tween_interval(finishInterval) # after crashing, shows crash, then reloads scene
	tween.tween_callback(get_tree().reload_current_scene)
	
func success_sequence(next_level_file: String) -> void:
	success_audio.play()
	success_particles.emitting = true
	is_transitioning = true
	set_process(false)
	var tween = create_tween()
	tween.tween_interval(finishInterval)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
