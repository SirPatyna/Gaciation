extends Node

func _ready():
	$Main_Menu/Panel/VBoxContainer/Host.grab_focus()
	Engine.max_fps = 60

const  Player = preload("res://scenes/FPScontroller/FPScontroller.tscn")
const  PLAZMA_PROJECTILE = preload("res://weapons/plazma/pocisk_plazma.tscn")
const  AUTOMAT_PROJECTILE = preload("res://weapons/automat/pocisk_automat.tscn")
const  MEGA_PROJECTILE = preload("res://weapons/mega/pocisk_mega.tscn")
const  SHOTGUN_PROJECTILE = preload("res://weapons/strzelba/pocisk_strzelba.tscn")
const  GRANATNIK_PROJECTILE = preload("res://weapons/granatnik/pocisk_granatnik.tscn")
const  MINA_PROJECTILE = preload("res://weapons/mina/pocisk_mina.tscn")

@onready var port = $"Main_Menu/Panel/VBoxContainer/HBoxContainer/port"
var enet_peer = ENetMultiplayerPeer.new()
@onready var ip = $"Main_Menu/Panel/VBoxContainer/HBoxContainer/ip"


#I renamed "Load" to "Host", prolly should reconnect this, but it works for now
#Done, cuz I reattached this script to the current top node from Main_Menu which was top node at the time
func _on_host_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/basic_world.tscn")
	$"Main_Menu".hide()
	
	enet_peer.create_server(int(port.text))
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	Engine.max_fps = 60
	
	add_player(multiplayer.get_unique_id())
	
	upnp_setup()
	#Commented out cuz it takes so long to load with this

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _on_join_pressed() -> void:
	$"Main_Menu".hide()
	enet_peer.create_client(ip.text, int(port.text))
	multiplayer.multiplayer_peer = enet_peer

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_settings_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$Main_Menu/Options.visible = true
	else:
		$Main_Menu/Options.visible = false


func _on_gamerules_toggled(_toggled_on: bool) -> void:
	pass # Replace with function body.


func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)

@rpc("any_peer", "call_local")
func spawn_projectile(projectile_position = Vector3(0,0,0), projectile_rotation = Vector3(0,0,0), head_rotation = Vector3(0,0,0), team = -1, damage:int = 0, projectile_speed = 0, player_speed = Vector3.ZERO, projectile_type = 0):
	var pocisk
	var temp_name = Engine.get_frames_drawn() * team
	match projectile_type:
		1:
			pocisk = MEGA_PROJECTILE.instantiate()
		2:
			pocisk = SHOTGUN_PROJECTILE.instantiate()
		3:
			pocisk = MINA_PROJECTILE.instantiate()
		4:
			pocisk = AUTOMAT_PROJECTILE.instantiate()
		5:
			pocisk = GRANATNIK_PROJECTILE.instantiate()
		_:
			pocisk = PLAZMA_PROJECTILE.instantiate()
	pocisk.add_speed = player_speed
	pocisk.team = team
	pocisk.position = projectile_position + Vector3(0, 1.75, 0)
	pocisk.name = StringName(str(temp_name))
	pocisk.damage = damage
	pocisk.projectile_speed = projectile_speed
	pocisk.initial_rotation = projectile_rotation
	pocisk.initial_rotation.x = head_rotation
	add_child(pocisk)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(int(port.text))
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
