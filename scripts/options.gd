extends Control

@onready var autobhop = $MarginContainer/VBoxContainer/Autobhop
@onready var fov = $MarginContainer/VBoxContainer/FOV
@onready var fahrenheit = $MarginContainer/VBoxContainer/Fahrenheit
@onready var interlace = $MarginContainer/VBoxContainer/Interlace

func _ready():
	var misc_settings = ConfigFileHandler.load_settings("misc")
	autobhop.button_pressed = misc_settings.auto_bhop
	fahrenheit.button_pressed = misc_settings.fahrenheit
	interlace.button_pressed = misc_settings.interlace
	fov.value = misc_settings.fov

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)


func _on_check_box_toggled(_toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_resolution_item_selected(index: int) -> void:
	DisplayServer.window_set_mode(0,0)
	match index:
		0:
			DisplayServer.window_set_size(DisplayServer.screen_get_size())
			DisplayServer.window_set_mode(3,0)
		1:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		2:
			DisplayServer.window_set_size(Vector2i(1280, 720))

func _on_fov_value_changed(value):
	ConfigFileHandler.save_setting("misc", "fov", value)
	$MarginContainer/VBoxContainer/Fov_Label.text = "\n Field of view: " + str(value)


func _on_autobhop_toggled(toggled_on):
	ConfigFileHandler.save_setting("misc", "auto_bhop", toggled_on)


func _on_fahrenheit_toggled(toggled_on: bool) -> void:
	ConfigFileHandler.save_setting("misc", "fahrenheit", toggled_on)


func _on_interlace_toggled(toggled_on: bool) -> void:
	ConfigFileHandler.save_setting("misc", "interlace", toggled_on)
