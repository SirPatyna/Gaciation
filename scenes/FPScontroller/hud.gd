extends CanvasModulate

@onready var player: CharacterBody3D = $".."

@onready var speed: Label = $Control/Velocity
@onready var temp: Label = $Control/Temp
@onready var debug_info: Label = $Control/debug_info
@onready var debug_backgroung: ColorRect = $Control/ColorRect2
@onready var frost_fx: TextureRect = $Control/Frozen_effect
@onready var stamina_meter: TextureProgressBar = $Control/Stamina_meter
@onready var jump = $"Control/Jump-o-meter"
@onready var ammo = $Control/Ammo
@onready var cross = $Control/crosshair
var fade_alpha = 0.0
var templocal = 0
var fahrenheit = ConfigFileHandler.load_settings("misc").fahrenheit

func _ready() -> void:
	if not is_multiplayer_authority(): $Control.visible = false
	frost_fx.size = DisplayServer.screen_get_size()
	@warning_ignore("integer_division")
	cross.position = Vector2(DisplayServer.screen_get_size().x/2,DisplayServer.screen_get_size().y * 0.44)
	
	$Panel.visible = ConfigFileHandler.load_settings("misc").interlace
	
	jump.max_value = player.max_air_jumps
	stamina_meter.max_value = player.stamina_max

func _process(_delta: float) -> void:
	if fahrenheit == true:
		templocal = LocalLib.round_to_dec(((float(player.temperature)/100)*1.8)+32, 2)
	else:
		templocal = LocalLib.round_to_dec((float(player.temperature)/100), 2)
	temp.text = str(templocal)+"°"
	if player.debug_on:
		debug_info.text = "Debug: " + str(player.debug_on) + "\n Auto bhop: " + str(ConfigFileHandler.load_settings("misc").auto_bhop) + "\n Friction: " + str(player.friction) + "\n Max stamina: " + str(player.stamina_max) + "\n Stamina left: " + str(player.stamina) + "\n Stamina per jump: " + str(player.stamina_per_jump) + "\n Stamina recover: " + str(player.stamina_recover) + "\n Max air jumps: " + str(player.max_air_jumps) + "\n Air jumps left: " + str(player.air_jumps_left) + "\n Heat rate: " + str(player.heat_rate) + "\n Cool rate: " + str(player.cool_rate) + "\n Current temp: " + str(player.temperature) + "\n Delta: " + str(LocalLib.round_to_dec(_delta, 3)) + "\n Team: " + str(player.team) + "\n FPS: " + str(Engine.get_frames_per_second()) + "\n" + str(Engine.physics_ticks_per_second) 
		speed.text = str(LocalLib.round_to_dec(player.vell, player.round_to))+" m/s (hor)\n"+ str(LocalLib.round_to_dec(player.vely, player.round_to))+" m/s (ver)"
	else:
		debug_info.visible = false
		debug_backgroung.visible = false
	
	match player.weapon_index:
		1:
			$Control/Ammo/Mega/Chunk1.value = player.ammo
		2:
			$Control/Ammo/Strzelba/Chunk1.value = player.ammo
		4:
			pass
		_:
			$Control/Ammo/Plazma/Chunk1.value = player.ammo
			$Control/Ammo/Plazma/Chunk2.value = player.ammo - 5
			$Control/Ammo/Plazma/Chunk3.value = player.ammo - 10
			$Control/Ammo/Plazma/Chunk4.value = player.ammo - 15
			$Control/Ammo/Plazma/Chunk5.value = player.ammo - 20
			$Control/Ammo/Plazma/Chunk6.value = player.ammo - 25
		#1:
		#2:
		#3:
		#4:
		#5:
		#6:
	
	
	stamina_meter.value = player.stamina
	jump.value = player.air_jumps_left
	
	if player.temperature >= player.max_temp-1 :
		fade_alpha = 0.0
	elif player.temperature == 0:
		fade_alpha = 1.0
	else:
		fade_alpha = -(1/LocalLib.round_to_dec(player.max_temp,5)*(2*LocalLib.round_to_dec(player.temperature, 2)-LocalLib.round_to_dec(player.max_temp,5)))
	frost_fx.modulate.a = fade_alpha
	
	
