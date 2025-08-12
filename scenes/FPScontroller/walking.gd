extends CharacterBody3D

var sensitivity = ConfigFileHandler.load_settings("keybinding").sensitivity


var player = 1

@export var friction = 5

@onready var ptr = Engine.physics_ticks_per_second


@export var max_air_jumps = 1
@export var stamina_max = 18
@export var stamina_per_jump =  2
@export var stamina_recover = 1

@export var vell = 0
@export var vely = 0
@export var round_to = 1

@export var max_temp = 3660
@export var heat_rate = 3
@export var cool_rate = 2
@export var team: int = 1

@export var debug_on = true

@export var weapon_index=int(0)
	#0: Plazma
	#1: Mega
	#2: Strzelba
	#3: Mina
	#4: Automat
	#5: Granatnik
	#6: BFG

@export var scoped = false
@export var fire_rate = 0.0

var auto_bhop = ConfigFileHandler.load_settings("misc").auto_bhop

var direction = Vector3()
var wish_jump
var second = 0.0
var air_jumps_left = max_air_jumps
var stamina = stamina_max
var temperature = max_temp
var refire_timer: int = 0
var ammo:int = 30
var reloading: bool = false
var reolading_timer: int = 20

const MAX_VELOCITY_AIR = 0.6
const MAX_VELOCITY_GROUND = 6.0
const MAX_ACCELERATION = 10 * MAX_VELOCITY_GROUND
const GRAVITY = 15.34
const STOP_SPEED = 1.5
const JUMP_IMPULSE = sqrt(2 * GRAVITY * 0.85)

#const  PLAZMA_PROJECTILE = preload("res://weapons/plazma/pocisk_plazma.tscn")



func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())
	team = name.to_int()

func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	process_input()
	process_movement()
	if reloading == true:
		reolading_timer -= 1
		if reolading_timer == 0:
			reolading_timer = 20
			ammo += 7
			%Player_cam/Reload_sound.play()
			if ammo >= %Weapon.max_ammo:
				ammo = %Weapon.max_ammo
				reloading = false
	
	if refire_timer >= 0:
		refire_timer -= 1
	vell = abs(velocity.x)+abs(velocity.z)
	vely = abs(velocity.y)
	
	if Engine.get_physics_frames()%10 == 0:
		if vell != 0:
			temperature += heat_rate
	
		if temperature > max_temp:
			temperature -= cool_rate
	
	if is_on_floor():
		second += 1
		@warning_ignore("integer_division")
		if second > ptr/2:
			@warning_ignore("integer_division")
			second -= ptr/2
			if stamina < stamina_max:
				stamina += stamina_recover
		
	if position.y < -50 : death.rpc()


func _process(_delta):
	#shader_mat.set_uniform_value("time", Engine.get_frames_drawn())
	%HeadViewModel.position = position #This is also stupid
	%HeadViewModel.rotation.y = rotation.y
	%HeadViewModel/Camera3D.rotation.x = %Head.rotation.x

func _ready():
	if not is_multiplayer_authority():
		%Weapon.visible = false
		%Head/SubViewportContainer.visible = false
		return
	%Player_cam.set_fov(ConfigFileHandler.load_settings("misc").fov)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	%Player_cam.current = true
	%WM.visible = false
	$Head/SubViewportContainer/SubViewport.size = DisplayServer.screen_get_size()

# Camera
func _input(event):
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_handle_camera_rotation(event)

		#Why, on the unholy fuck, I can't get render on the client
		#UPDATE: Now I'm getting client render on the host, what the actuall fuck
		#UPDATE: reenabling if in _ready fixed client render on the host but we're back to the first problem
		#UP THE FUCKING DATE: I DID IT, I SOLVED IT
		#Left for future reference of my stupidity

func cam_walljump_rotation(wall_normal: Vector3):
	var wall_normal_2d = Vector2(-wall_normal.x, wall_normal.z)
	rotation.y = 0 #This is shitty fix but it works
	rotate_y(wall_normal_2d.angle()+deg_to_rad(90))

func _handle_camera_rotation(event: InputEvent):
	if not is_multiplayer_authority(): return
	# Rotate the camera based on the mouse movement
	rotate_y(deg_to_rad(-event.relative.x * sensitivity))
	$Head.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
	
	# Stop the head from rotating to far up or down
	$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-85), deg_to_rad(85))



func process_input():
	direction = Vector3()
	
	# Movement directions
	if Input.is_action_pressed("up"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("down"):
		direction += transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("right"):
		direction += transform.basis.x
	
	# Jumping
	if is_on_floor():
		if auto_bhop == true: #If you have abhop on it just checks if you have pressed jump on the floor
			wish_jump = Input.is_action_pressed("jump")
		else: #If not you'll have to press it every time
			wish_jump = Input.is_action_just_pressed("jump")
	else: #This else is for double jump so you dont jump right after normal jumps
		wish_jump = Input.is_action_just_pressed("jump")
	
	
	if Input.is_action_pressed("primary_fire"):
		primary_fire_pressed()
	
	if Input.is_action_just_pressed("secondary_fire"):
		secondary_fire_pressed.rpc()
	
	if Input.is_action_just_pressed("change_weapon"):
		if not (weapon_index == 0 and ammo == %Weapon.max_ammo): 
			weapon_index = 0
			ammo = 0
		change_weapon.rpc()
	
	if Input.is_action_pressed("weapon_next"):
		pass
	if Input.is_action_pressed("weapon_previous"):
		pass

func process_movement():
	# Get the normalized input direction so that we don't move faster on diagonals
	var wish_dir = direction.normalized()
	
	if is_on_floor():
		# If wish_jump is true then we won't apply any friction and allow the 
		# player to jump instantly, this gives us a single frame where we can 
		# perfectly bunny hop
		if wish_jump:
			velocity.y = JUMP_IMPULSE
			# Update velocity as if we are in the air
			velocity = update_velocity_air(wish_dir)
			jump_sound.rpc()
			wish_jump = false
		else:
			velocity = update_velocity_ground(wish_dir)
		air_jumps_left = max_air_jumps
	elif is_on_wall_only(): #Wall jump
		if wish_jump and stamina >= stamina_per_jump:
			velocity.y = JUMP_IMPULSE * 1.75
			velocity = update_velocity_air(wish_dir)
			velocity.x = get_wall_normal().x * JUMP_IMPULSE * 1.75
			velocity.z = get_wall_normal().z * JUMP_IMPULSE * 1.75
			cam_walljump_rotation(get_wall_normal())
			jump_sound.rpc()
			wish_jump = false
			stamina -= stamina_per_jump
		else:
			velocity.y -= GRAVITY / ptr
			velocity = update_velocity_air(wish_dir)
		air_jumps_left = max_air_jumps
	else:
		 # air jump
		if air_jumps_left > 0 and stamina >= stamina_per_jump and wish_jump:
			velocity.y = JUMP_IMPULSE * 1.5
			velocity = update_velocity_air(wish_dir)
			velocity.x = wish_dir.x * JUMP_IMPULSE * 1.5
			velocity.z = wish_dir.z * JUMP_IMPULSE * 1.5
			jump_sound.rpc()
			air_jumps_left -= 1
			stamina -= stamina_per_jump
			wish_jump = false
		# Only apply gravity while in the air
		else:
			velocity.y -= GRAVITY / ptr
			velocity = update_velocity_air(wish_dir)

	# Move the player once velocity has been calculated
	
	move_and_slide()

func accelerate(wish_dir: Vector3, max_velocity: float):
	# Get our current speed as a projection of velocity onto the wish_dir
	var current_speed = velocity.dot(wish_dir)
	# How much we accelerate is the difference between the max speed and the current speed
	# clamped to be between 0 and MAX_ACCELERATION which is intended to stop you from going too fast
	var add_speed = clamp(max_velocity - current_speed, 0, MAX_ACCELERATION / ptr)
	return velocity + add_speed * wish_dir
	
func update_velocity_ground(wish_dir: Vector3):
	# Apply friction when on the ground and then accelerate
	var speed = velocity.length() 
	
	if speed != 0:
		var control = max(STOP_SPEED, speed)
		var drop = control * friction / ptr
		
		# Scale the velocity based on friction
		velocity *= max(speed - drop, 0) / speed
	
	return accelerate(wish_dir, MAX_VELOCITY_GROUND)
	
func update_velocity_air(wish_dir: Vector3):
	# Do not apply any friction
	return accelerate(wish_dir, MAX_VELOCITY_AIR)


@rpc("call_local")
func jump_sound():
	$Foot_sound.set_pitch_scale(randf_range(0.75, 1.25))
	$Foot_sound.play()

#@rpc("call_local")
func  primary_fire_pressed() -> void:
	if reloading == true:
		return
	if ammo <= 0: 
		weapon_index = 0
		change_weapon.rpc()
	if refire_timer >= 0:
		return
	%Player_cam/Shoot_sound.play()
	refire_timer = floor(ptr * (1/%Weapon.fire_rate))
	match weapon_index:
		2:
			$"..".spawn_projectile.rpc(position, rotation + Vector3(0, PI/20,0), %Head.rotation.x + PI/20, team,  %Weapon.damage, %Weapon.projectile_speed, velocity, weapon_index)
			$"..".spawn_projectile.rpc(position, rotation + Vector3(0, PI/20,0), %Head.rotation.x - PI/20, team,  %Weapon.damage, %Weapon.projectile_speed, velocity, weapon_index)
			$"..".spawn_projectile.rpc(position, rotation - Vector3(0, PI/20,0), %Head.rotation.x + PI/20, team,  %Weapon.damage, %Weapon.projectile_speed, velocity, weapon_index)
			$"..".spawn_projectile.rpc(position, rotation - Vector3(0, PI/20,0), %Head.rotation.x - PI/20, team,  %Weapon.damage, %Weapon.projectile_speed, velocity, weapon_index)
			$"..".spawn_projectile.rpc(position, rotation, %Head.rotation.x, team,  %Weapon.damage, %Weapon.projectile_speed, velocity, weapon_index)
		4:
			var randy = randi_range(0,1)
			match randy:
				0:
					$"..".spawn_projectile.rpc(position, rotation + Vector3(0, PI/randf_range(-200.0, -20.0),0), %Head.rotation.x + PI/randf_range(-200.0, -20.0), team,  %Weapon.damage, %Weapon.projectile_speed, velocity, weapon_index)
				1:
					$"..".spawn_projectile.rpc(position, rotation - Vector3(0, PI/randf_range(-200.0, -20.0),0), %Head.rotation.x - PI/randf_range(-200.0, -20.0), team,  %Weapon.damage, %Weapon.projectile_speed, velocity, weapon_index)
				2:
					$"..".spawn_projectile.rpc(position, rotation + Vector3(0, PI/randf_range(-200.0, -20.0),0), %Head.rotation.x - PI/randf_range(-200.0, -20.0), team,  %Weapon.damage, %Weapon.projectile_speed, velocity, weapon_index)
				3:
					$"..".spawn_projectile.rpc(position, rotation - Vector3(0, PI/randf_range(-200.0, -20.0),0), %Head.rotation.x + PI/randf_range(-200.0, -20.0), team,  %Weapon.damage, %Weapon.projectile_speed, velocity, weapon_index)

		_:
			$"..".spawn_projectile.rpc(position, rotation, %Head.rotation.x, team,  %Weapon.damage, %Weapon.projectile_speed, velocity, weapon_index)
	ammo -= 1
	

@rpc("any_peer")
func receive_damage(incoming_damage:int = 0):
	temperature = temperature - incoming_damage
	if temperature < 0 : death.rpc()
	

@rpc("call_local")
func secondary_fire_pressed() -> void:
	if weapon_index == 1 && scoped == false:
		scoped = true
		%HeadViewModel/Camera3D.set_fov(%HeadViewModel/Camera3D.fov/2)
		%Player_cam.set_fov(ConfigFileHandler.load_settings("misc").fov/3)
	elif weapon_index == 1 && scoped == true:
		scoped = false
		%Player_cam.set_fov(ConfigFileHandler.load_settings("misc").fov)
		%HeadViewModel/Camera3D.set_fov(%HeadViewModel/Camera3D.fov*2)

@rpc("call_local")
func change_weapon():
	
	
	
	if scoped == true:
		scoped = false
		%Player_cam.set_fov(ConfigFileHandler.load_settings("misc").fov)
		%HeadViewModel/Camera3D.set_fov(%HeadViewModel/Camera3D.fov*2)
	$CanvasModulate/Control/Ammo/Plazma.visible = false
	$CanvasModulate/Control/Ammo/Automat.visible = false
	$CanvasModulate/Control/Ammo/Mega.visible = false
	$CanvasModulate/Control/Ammo/Strzelba.visible = false
	match weapon_index:
		0:
			%Weapon.WEAPON_TYPE = load("res://weapons/plazma/plazma_script.tres")
			$CanvasModulate/Control/Ammo/Plazma.visible = true
		1:
			%Weapon.WEAPON_TYPE = load("res://weapons/mega/mega_script.tres")
			$CanvasModulate/Control/Ammo/Mega.visible = true
		2:
			%Weapon.WEAPON_TYPE = load("res://weapons/strzelba/strzelba_script.tres")
			$CanvasModulate/Control/Ammo/Strzelba.visible = true
		3:
			%Weapon.WEAPON_TYPE = load("res://weapons/mina/mina_script.tres")
		4:
			%Weapon.WEAPON_TYPE = load("res://weapons/automat/automat_script.tres")
			$CanvasModulate/Control/Ammo/Automat.visible = true
		5:
			%Weapon.WEAPON_TYPE = load("res://weapons/granatnik/granatnik_script.tres")
		6:
			%Weapon.WEAPON_TYPE = load("res://weapons/bfg/bfg_script.tres")
		_:
			%Weapon.WEAPON_TYPE = load("res://weapons/plazma/plazma_script.tres")
			$CanvasModulate/Control/Ammo/Plazma.visible = true
	%Weapon.load_weapons.rpc()
	if weapon_index == 0 and ammo < %Weapon.max_ammo:
		reloading = true
	else:
		ammo = %Weapon.max_ammo

@rpc("call_local")
func death():
		temperature = 0
		position = Vector3.ZERO
		weapon_index = 0
		change_weapon.rpc()
		velocity = Vector3.ZERO
		$WM/crystal_27.visible = true
