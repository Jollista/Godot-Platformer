extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mousePos
var playerPos

onready var player := $"../Player"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# get mouse position and player position
	mousePos = get_global_mouse_position()
	playerPos = player.position
#	print("Mouse Pos: " + String(mousePos))
#	print("Player Pos: " + String(playerPos))
	if Input.is_action_pressed("sneak"):
		position.x = (mousePos.x + playerPos.x)/2
		position.y = (mousePos.y + playerPos.y)/2
	else:
		position.x = (mousePos.x + 4 * playerPos.x)/5
		position.y = (mousePos.y + 4 * playerPos.y)/5
