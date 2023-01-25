# TO DO:
# - Make options menu actually edit the json by writing to file, ya goof
# - make OptionsMenuPopup its own scene and have it replace PauseMenu's version
#	of the options menu. I don't wanna have to edit shit twice.

extends WindowDialog

# text speeds
const FAST = 0.01
const NORM = 0.025
const SLOW = 0.05

# reference to settings.JSON file which contains the settings
var settingsJSON
# file variable for settings.JSON management
var file = File.new()
# used to help determine when window is closed
var lastVisCheck

func _ready():
	if file.file_exists("res://settings.json"):
		file.open("res://settings.json", file.READ)
		settingsJSON = parse_json(file.get_as_text())
		file.close()
	
	# initialize volume sliders
	$MasterVolumeLabel/MasterVolumeSlider.value = settingsJSON[0]["MasterVol"]+80
	$MusicVolumeLabel/MusicVolumeSlider.value = settingsJSON[0]["MusicVol"]+80
	$SFXVolumeLabel/SFXVolumeSlider.value = settingsJSON[0]["SFXVol"]+80

func _input(event):
	if (!visible and lastVisCheck):
		# window has been closed
		if file.file_exists("res://settings.json"):
			file.open("res://settings.json", file.WRITE)
			file.store_line(to_json(settingsJSON))
			file.close()
		print(String(settingsJSON))
	lastVisCheck = visible

func _on_MasterVolumeSlider_value_changed(value):
	# change volume and update settings json
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value-80)
	settingsJSON[0]["MasterVol"] = value-80

func _on_MusicVolumeSlider_value_changed(value):
	# change volume and update settings json
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value-80)
	settingsJSON[0]["MusicVol"] = value-80

func _on_SFXVolumeSlider_value_changed(value):
	# change volume and update settings json
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Player SFX"), value-80)
	settingsJSON[0]["SFXVol"] = value-80

func _on_SlowTextButton_pressed():
	# only needs to set in JSON since it's only changed once before gameplay
	settingsJSON[0]["TextSpeed"] = SLOW

func _on_NormTextButton_pressed():
	# only needs to set in JSON since it's only changed once before gameplay
	settingsJSON[0]["TextSpeed"] = NORM

func _on_FastTextButton_pressed():
	# only needs to set in JSON since it's only changed once before gameplay
	settingsJSON[0]["TextSpeed"] = FAST
