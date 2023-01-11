extends CanvasLayer

# path to default dialogue file json (should never play)
# see NPC export var for used pathtofile by default based on NPC
# since there should only be one of these per scene, but can be multiple NPCs
export(String, FILE, "*.json") var dialogueFile

# delay between ending one dialogue and starting a new one
const DIALOGUE_DELAY = 0.1

# array of lines
var dialogue = []
# index of current line
var currentDialogue = 0
# is dialogue active
var active = false

func _ready():
	visible = false

func startDialogue(filepath:String = ""):
	if !$DialogueDelay.is_stopped():
		return
	
	# if given filepath, load that instead of default
	if filepath != "" and filepath != null:
		dialogueFile = filepath
	print("dialogueFile:" + dialogueFile)
	
	# load dialogue
	dialogue = loadDialogue()
	
	# reset index and set visible/active true
	currentDialogue = 0
	visible = true
	active = true
	
	# freeze player in place
	$"../Player".freeze()
	
	# update text
	nextLine()

func loadDialogue():
	var file = File.new()
	if file.file_exists(dialogueFile):
		file.open(dialogueFile, file.READ)
		return parse_json(file.get_as_text())

# progress dialogue
func _input(event):
	if active and (Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept")):
			nextLine()

func nextLine():
	# if index is out of bounds, end dialogue
	if currentDialogue >= len(dialogue):
		endDialogue()
		return
	
	# update text
	$DialogueBox/Name.text = dialogue[currentDialogue]["Name"]
	$DialogueBox/Chat.text = dialogue[currentDialogue]["Text"]
	
	# increment index
	currentDialogue += 1

func endDialogue():
	# reset variables
	visible = false
	active = false
	
	# unfreeze player
	$"../Player".unfreeze()
	
	# start delay between starting dialogues
	$DialogueDelay.start(DIALOGUE_DELAY)
