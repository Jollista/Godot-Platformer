extends Control

var toggle = false

func _on_StartButton_pressed():
	get_tree().change_scene("res://PlatformerSceneTest.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_OptionsButton_pressed():
	$OptionsMenuPopup.popup()
