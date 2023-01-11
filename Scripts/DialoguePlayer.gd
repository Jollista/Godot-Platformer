extends CanvasLayer

# path to default dialogue file json (should never play)
# see NPC export var for used pathtofile by default based on NPC
# since there should only be one of these per scene, but can be multiple NPCs
export(String, FILE, "*.json") var dialogueFile

# delay between ending one dialogue and starting a new one
const DIALOGUE_DELAY = 0.1
# text speeds
const FAST = 0.01
const NORM = 0.025
const SLOW = 0.05

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
	
	# set wait time between displaying characters
	$DialogueDelay.set_wait_time(NORM)
	# initial yield before it matters bc that one messes with 
	#$DialogueBox/Chat.visible_characters for some reason
	$DialogueDelay.start()
	yield($DialogueDelay, "timeout")
	
	# reset index and set visible/active true
	currentDialogue = 0
	visible = true
	active = true
	
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
	
	# update text, works with bbcode
	$DialogueBox/Name.bbcode_text = dialogue[currentDialogue]["Name"]
	$DialogueBox/Chat.bbcode_text = dialogue[currentDialogue]["Text"]
	print("Updating text, currentDialogue: " + String(currentDialogue))
	
	# increment index
	currentDialogue += 1
	
	# clear textbox
	$DialogueBox/Chat.visible_characters = 0
	
	# write phrase
	print("Text: " + $DialogueBox/Chat.text)
	var j = 0
	for i in $DialogueBox/Chat.text:
		print("char[" + String(j) + "]: " + i)
		j += 1
	print("Length: " + String(len($DialogueBox/Chat.text)))
	print("visible_characters: " + String($DialogueBox/Chat.visible_characters))
	print(String($DialogueBox/Chat.visible_characters < len($DialogueBox/Chat.text)))
	while $DialogueBox/Chat.visible_characters < len($DialogueBox/Chat.text):
		$DialogueBox/Chat.visible_characters += 1 # make next char visible
		
		# delay between characters made visible
		$DialogueDelay.start()
		
		# I don't know why, but during yield's call, visible_characters is set to max
		# for the first line in a dialogue. I don't understand why this is.
		# It's just for the first line. The rest work perfect. It's dumb.
		# I figured out that this only happens with the first time yield is called,
		# so I got around it by starting a timer and yielding before anything is visible
		# in startDialogue(), that way it looks fine and if it looks right, it's right, right?
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
