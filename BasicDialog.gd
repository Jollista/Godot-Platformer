extends ColorRect

export var dialogPath = ""
export(float) var textSpeed = 0.05

var dialog

var phraseNum = 0
var finished = false

func _ready():
	$Indicator/AnimationPlayer.play("Indicate")
	$Timer.set_wait_time(textSpeed)
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	nextPhrase()

func _process(delta):
	$Indicator.visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		if finished: # go to next phrase
			nextPhrase()
		else: # skip dialog animation
			$Text.visible_characters = len($Text.text)

# get dialog from .json
func getDialog() -> Array:
	var f = File.new()
	assert(f.file_exists(dialogPath), "File path does not exist")
	
	f.open(dialogPath, File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)
	
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []

func nextPhrase() -> void:
	if phraseNum >= len(dialog):
		queue_free()
		return
	
	finished = false
	
	# works with bbcode tags
	$Name.bbcode_text = dialog[phraseNum]["Name"]
	$Text.bbcode_text = dialog[phraseNum]["Text"]
	
	# clear textbox
	$Text.visible_characters = 0
	
	# handle sprites
	var f = File.new()
	var img = dialog[phraseNum]["Name"] + dialog[phraseNum]["Emotion"] + ".png"
	if f.file_exists(img):
		$"../Portrait".texture = load(img)
	else: 
		#$"../Portrait".texture = null
		pass
	
	# write phrase
	while $Text.visible_characters < len($Text.text):
		$Text.visible_characters += 1 # make next char visible
		
		$Timer.start()
		yield($Timer, "timeout") # delay while loop until timeout
	
	finished = true
	return
