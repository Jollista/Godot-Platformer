extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var toggle = false

# reference to settings.JSON file which contains the settings
var settingsJSON

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = File.new()
	if file.file_exists("res://settings.json"):
		file.open("res://settings.json", file.READ)
		settingsJSON = parse_json(file.get_as_text())

func _on_OptionsButton_pressed():
	#toggleOptionsMenu()
	pass

func toggleOptionsMenu():
	pass

func _on_BackButton_pressed():
	toggleOptionsMenu()

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
	$"../DialogueCanvas".textSpeed = $"../DialogueCanvas".SLOW
	settingsJSON[0]["TextSpeed"] = "SLOW"

func _on_MedTextButton_pressed():
	$"../DialogueCanvas".textSpeed = $"../DialogueCanvas".NORM
	settingsJSON[0]["TextSpeed"] = "NORM"

func _on_FastTextButton_pressed():
	$"../DialogueCanvas".textSpeed = $"../DialogueCanvas".FAST
	settingsJSON[0]["TextSpeed"] = "FAST"

func _on_StartButton_pressed():
	get_tree().change_scene("res://PlatformerSceneTest.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
