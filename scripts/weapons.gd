@icon("res://textures/famas.svg")
class_name Weapons extends Resource

@export var name: StringName
@export_category("Weapon Orientation")
@export var position : Vector3
@export var rotation : Vector3
@export_category("Visual Settings")
@export var mesh : Mesh
@export var material : Material
@export var shadow : bool
@export_category("Weapon_stats")
@export var damage : int = 0
@export var max_ammo : int
@export var projectile_speed : float
@export var projectile_max_bounces : int
@export var projectile_life_time : float
@export var fire_rate: float
