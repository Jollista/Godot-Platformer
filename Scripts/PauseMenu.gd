extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var toggle = false

# reference to settings.JSON file which contains the settings
var settingsJSON

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	var file = File.new()
	if file.file_exists("res://settings.json"):
		file.open("res://settings.json", file.READ)
		settingsJSON = parse_json(file.get_as_text())

func _input(event):
	if Input.is_action_just_pressed("pause"):
		# toggle menu visibility/interactability
		visible = !visible
		toggle = !$VBoxContainer/ResumeButton.disabled
		$VBoxContainer/ResumeButton.disabled = toggle
		$VBoxContainer/OptionsButton.disabled = toggle
		$VBoxContainer/QuitButton.disabled = toggle
		
		# grabfocus if menu is visible
		if visible:
			$VBoxContainer/ResumeButton.grab_focus()
		
		# toggle player movement
		$"../Player".toggleMovement()
		
		# apply filter to sound effects
		AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Master"), 3, visible)	# low pass

func _on_ResumeButton_pressed():
	visible = false
	$VBoxContainer/ResumeButton.disabled = true
	$VBoxContainer/OptionsButton.disabled = true
	$VBoxContainer/QuitButton.disabled = true
	$"../Player".unfreeze()

func _on_OptionsButton_pressed():
	toggleOptionsMenu()

func toggleOptionsMenu():
	var vis = $VBoxContainer/ResumeButton.visible
	var disabled = $VBoxContainer/ResumeButton.disabled
	
	# set default menu buttons invisible/disabled
	$VBoxContainer/ResumeButton.disabled = !disabled
	$VBoxContainer/ResumeButton.visible = !vis
	$VBoxContainer/OptionsButton.disabled = !disabled
	$VBoxContainer/OptionsButton.visible = !vis
	$VBoxContainer/QuitButton.disabled = !disabled
	$VBoxContainer/QuitButton.visible = !vis
	
	# set options menu stuff visible/enabled
	# text speeds
	$VBoxContainer/TextSpeedLabel.visible = vis
	$VBoxContainer/SlowTextButton.disabled = disabled
	$VBoxContainer/SlowTextButton.visible = vis
	$VBoxContainer/MedTextButton.disabled = disabled
	$VBoxContainer/MedTextButton.visible = vis
	$VBoxContainer/FastTextButton.disabled = disabled
	$VBoxContainer/FastTextButton.visible = vis
	
	# volume
	$VBoxContainer/MasterVolumeLabel.visible = vis
	$VBoxContainer/MasterVolumeSlider.visible = vis
	
	$VBoxContainer/MusicVolumeLabel.visible = vis
	$VBoxContainer/MusicVolumeSlider.visible = vis
	
	$VBoxContainer/SFXVolumeLabel.visible = vis
	$VBoxContainer/SFXVolumeSlider.visible = vis
	
	$VBoxContainer/BackButton.disabled = disabled
	$VBoxContainer/BackButton.visible = vis
	
	# grab focus
	if vis: # options menu
		$VBoxContainer/BackButton.grab_focus()
	else: # default pause menu
		$VBoxContainer/ResumeButton.grab_focus()

func _on_QuitButton_pressed():
	get_tree().quit()

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
