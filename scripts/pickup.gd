@tool

extends Node3D

@export var type: int = -1
@export var respawn_time: int = 10
var respawning_timer: int = 0
var picked: bool = false

func _ready() -> void:
	%Placeholder.visible = false
	match type:
		-1: 	#Empty
			pass
		0:  	#Plazma but don't use
			%Plazma.visible = true
		1:  	#Mega
			%Mega.visible = true
		2:  	#Strzelba
			%Strzelba.visible = true
		3:  	#Mina
			%Mina.visible = true
		4:  	#Automat
			%Automat.visible = true
		5:  	#Granatnik
			%Granatnik.visible = true
		6:  	#BFG
			%BFG.visible = true
			pass
		10:
			%Health.visible = true

func _physics_process(delta: float) -> void:
	$Rotating_bone.rotation.y += LocalLib.TRUEPI * delta
	
	if picked == true:
		respawning_timer += 1
	
	if respawning_timer >= respawn_time * Engine.physics_ticks_per_second:
		respawning_timer = 0
		picked = false
		$Rotating_bone.visible = true



func _on_area_3d_body_entered(body: Node3D) -> void:
	if picked == true:
		return
	
	if not body is CharacterBody3D:
		return
		
	if not "player" in body:
		return
		
	match type:
		0, 1, 2, 3, 4, 5, 6, 7, 8, 9:
			body.weapon_index=int(type)
			body.change_weapon.rpc()
		10:
			if body.temperature < body.max_temp:
				#body.receive_damage.rpc_id(body.get_multiplayer_authority(), -600)
				body.temperature += 600
			else:
				return
	hidding.rpc()

@rpc("call_local")
func hidding():
	$Rotating_bone.visible = false
	picked = true
