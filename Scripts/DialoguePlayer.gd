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
# is current line finished displaying
var finished = true

func _ready():
	$Indicator/AnimationPlayer.play("Bob")
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
	
	# set wait time between displaying characters
	$DialogueDelay.set_wait_time(0.01)
	
	# freeze player in place
	$"../Player".freeze()
	
	# update text
	nextLine()

# load and parse dialogue from JSON file
func loadDialogue():
	var file = File.new()
	if file.file_exists(dialogueFile):
		file.open(dialogueFile, file.READ)
		return parse_json(file.get_as_text())

# handles dialogue progression
func _process(delta):
	$Indicator.visible = finished
	if active and (Input.is_action_just_pressed("ui_accept") || Input.is_action_just_pressed("interact")):
		if finished: # go to next line
			nextLine()
		else: # skip dialog animation
			$DialogueBox/Chat.visible_characters = len($DialogueBox/Chat.text)

func nextLine():
	# update vars
	finished = false
	
	# if index is out of bounds, end dialogue
	if currentDialogue >= len(dialogue):
		endDialogue()
		return
	
	# update text
	$DialogueBox/Name.text = dialogue[currentDialogue]["Name"]
	$DialogueBox/Chat.text = dialogue[currentDialogue]["Text"]
	print("Updating text, currentDialogue: " + String(currentDialogue))
	
	# increment index
	currentDialogue += 1
	
	# clear textbox
	$DialogueBox/Chat.visible_characters = 0
	# write phrase
	while $DialogueBox/Chat.visible_characters < len($DialogueBox/Chat.text):
		$DialogueBox/Chat.visible_characters += 1 # make next char visible
		# delay between characters made visible
		$DialogueDelay.start()
		yield($DialogueDelay, "timeout") # delay while loop until timeout
	finished = true
	return

func endDialogue():
	# reset variables
	visible = false
	active = false
	currentDialogue = 0
	print("Ending dialogue, currentDialogue: " + String(currentDialogue))
	
	# unfreeze player
	$"../Player".unfreeze()
	
	# start delay between starting dialogues
	$DialogueDelay.start(DIALOGUE_DELAY)
