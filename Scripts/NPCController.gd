extends KinematicBody2D

const INTERACT_DISTANCE = 50

export var dialogPath = ""

# get reference to Player in scene
onready var player := $"../Player"

func _ready():
	$AnimationPlayer.play("Viking_Idle")

func _process(delta):
	# distance formula -> √((x2 – x1)² + (y2 – y1)²)
	var distance = pow((player.global_position.x - global_position.x), 2) + pow((player.global_position.y - global_position.y), 2)
	distance = sqrt(distance)
	
	# if within range, interacting, and can move
	if distance <= INTERACT_DISTANCE and Input.is_action_just_pressed("interact") and $"../Player".canMove:
		$"../DialogueCanvas".startDialogue(dialogPath)
