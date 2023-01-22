extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var toggle = false

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func _input(event):
	if Input.is_action_just_pressed("pause"):
		visible = !visible
		toggle = !$VBoxContainer/ResumeButton.disabled
		$VBoxContainer/ResumeButton.disabled = toggle
		$VBoxContainer/OptionsButton.disabled = toggle
		$VBoxContainer/QuitButton.disabled = toggle
		if !toggle:
			$VBoxContainer/ResumeButton.grab_focus()
		$"../Player".toggleMovement()

func _on_ResumeButton_pressed():
	visible = false
	$VBoxContainer/ResumeButton.disabled = true
	$VBoxContainer/OptionsButton.disabled = true
	$VBoxContainer/QuitButton.disabled = true
	$"../Player".unfreeze()

func _on_OptionsButton_pressed():
	# Text speed (Slow, Med, Fast)
	# Volume (master, music, sfx)
	pass

func _on_QuitButton_pressed():
	get_tree().quit()
