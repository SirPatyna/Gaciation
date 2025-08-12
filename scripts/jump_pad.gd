@tool

extends Node3D

@export var impulse = 15
#@export_range(1, 2) var type:int = 1

func _on_area_3d_body_entered(body: Node3D) -> void:
#	if type == 1:
#		if body.velocity.y < 0: body.velocity.y = impulse
#		else: body.velocity.y += impulse
#	else:
#		if body.velocity.y < 0: body.velocity.y = impulse/2
#		else: body.velocity.y += impulse/2
#		var push = body.rotation.y
	
	if not body is CharacterBody3D:
		return
	
	if not "player" in body:
		return
	
	body.velocity.y = impulse
	body.air_jumps_left = body.max_air_jumps
	play_sound.rpc()

@rpc("call_local")
func play_sound():
	$Launch_sound.set_pitch_scale(randf_range(0.75, 1.25))
	$Launch_sound.play()
