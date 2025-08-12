@tool

extends Node3D

@export var WEAPON_TYPE : Weapons
@export var damage:int = 0
@export var max_ammo:int = 0
var projectile_speed = 0
var fire_rate = 0

@onready var weapon_mesh : MeshInstance3D = %Current_weapon

func _ready() -> void:
	load_weapons()

@rpc("call_local")
func load_weapons():
	if not is_multiplayer_authority(): return
	weapon_mesh.mesh = WEAPON_TYPE.mesh
	weapon_mesh.material_override = WEAPON_TYPE.material
	weapon_mesh.position = WEAPON_TYPE.position
	weapon_mesh.rotation_degrees = WEAPON_TYPE.rotation
	damage = WEAPON_TYPE.damage
	projectile_speed = WEAPON_TYPE.projectile_speed
	max_ammo = WEAPON_TYPE.max_ammo
	fire_rate = WEAPON_TYPE.fire_rate
