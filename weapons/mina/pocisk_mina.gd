extends CharacterBody3D

@export var team = -1
const GRAVITY = 15.34
@onready var ptr = Engine.physics_ticks_per_second
var initial_rotation: Vector3
var direction: Vector3
var add_speed: Vector3
var damage:int = 0
var projectile_speed: float
var time_to_live = 45

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not "player" in body:
		return
	if body.team != team:
		body.receive_damage.rpc_id(body.get_multiplayer_authority(), damage)
		self.queue_free()

func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if not "player" in body:
		return
	if body.team != team:
		$Area3D.monitoring = true

func _ready() -> void:
	rotation = initial_rotation
	direction -= transform.basis.z 
	velocity = (Vector3(projectile_speed,projectile_speed,projectile_speed) * direction.normalized()) #+ add_speed
	rotation = Vector3.ZERO
	
	

func _physics_process(_delta: float) -> void:
	
	time_to_live -= 1
	
	if time_to_live <= 0:
		$Area3D_2.monitoring = true
	
	
	if $Area3D_2.monitoring:
		return
	
	var collision = move_and_collide(velocity / ptr)
	
	if not is_on_floor(): velocity.y -= GRAVITY * 0.65 / ptr
	
	if position.y <= -50: self.queue_free()
	
	if collision:
		velocity = velocity.bounce(collision.get_normal())
