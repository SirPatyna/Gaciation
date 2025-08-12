extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("keybinding", "left", "A")
		config.set_value("keybinding", "right", "D")
		config.set_value("keybinding", "up", "W")
		config.set_value("keybinding", "down", "S")
		config.set_value("keybinding", "jump", "Space")
		config.set_value("keybinding", "sensitivity", 0.25)
		
		config.set_value("audio", "master_volume", 1.0)
		
		config.set_value("misc", "fov", 75.0)
		config.set_value("misc", "auto_bhop", true)
		config.set_value("misc", "fahrenheit", false)
		config.set_value("misc", "interlace", false)
		
		config.set_value("gamerule-movement", "max_air_jumps", 1)
		config.set_value("gamerule-movement", "stamina_max", 18)
		config.set_value("gamerule-movement", "stamina_per_jump", 2)
		config.set_value("gamerule-movement", "stamina_recover", 1)
		
		config.set_value("gamerule-temperature", "max_temperature", 36.60)
		config.set_value("gamerule-temperature", "heat_rate", 3.0)
		config.set_value("gamerule-temperature", "cool_rate", 2.0)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)

func save_setting(where: String, key: String, value):
	config.set_value(where, key, value)
	config.save(SETTINGS_FILE_PATH)


func load_settings(where):
	config.load(SETTINGS_FILE_PATH)
	var setting = {}
	for key in config.get_section_keys(where):
		setting[key] = config.get_value(where, key)
	return setting
