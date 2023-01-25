extends CanvasLayer

# text speeds
const FAST = 0.01
const NORM = 0.025
const SLOW = 0.05

# variable used to toggle visibility/interactability across the board
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
	$OptionsMenuPopup.popup()

func _on_QuitButton_pressed():
	get_tree().quit()
