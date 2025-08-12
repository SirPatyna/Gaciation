extends CharacterBody3D

@export var team = -1
@onready var ptr = Engine.physics_ticks_per_second
var initial_rotation: Vector3
var direction: Vector3
var add_speed: Vector3
var damage:int = 0
var projectile_speed: float
var sprite_change:bool = false
var sprite_frame:int = 4
var time_to_live = 20


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not "player" in body:
		return
	if body.team != team:
		body.receive_damage.rpc_id(body.get_multiplayer_authority(), damage)
		self.queue_free()

func _ready() -> void:
	rotation = initial_rotation
	direction -= transform.basis.z 
	velocity = (Vector3(projectile_speed,projectile_speed,projectile_speed) * direction.normalized()) + add_speed
	
	

func _physics_process(_delta: float) -> void:
	time_to_live -= 1
	if time_to_live == 0: self.queue_free()
	
	
	var collision = move_and_collide(velocity / ptr)
	
	if position.y <= -50: self.queue_free()
	
	if collision: self.queue_free()
