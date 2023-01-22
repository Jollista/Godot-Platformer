extends KinematicBody2D

# constants for player movement
const UP = Vector2.UP
const GRAVITY = 20
const MAX_FALL_SPEED = 200
const MAX_SPEED = 200
const JUMP_FORCE = 400
const ACCELERATION = 15
const ROLL_SPEED = 200
const DASH_SPEED = 250

# variables for motion and animation
var motion = Vector2()
var facingRight = true
var falling = false
var hasLanded = true
var canMove = true

# variables for audio handling
var played = false

# onready references to child nodes
onready var sprite := $Sprite
onready var anim := $AnimationPlayer
onready var dashDelayTimer := $DashDelayTimer
onready var rollDelayTimer := $RollDelayTimer
onready var sfx := $SFX

export var dashDelay: float = 0.5
export var rollDelay: float = 0.7

# exported random pitch audiostreams for player sfx
export(AudioStreamRandomPitch) var dashSound
export(AudioStreamRandomPitch) var rollSound
export(AudioStreamRandomPitch) var jumpSound
export(AudioStreamRandomPitch) var runSound

func _input(event):
	# do nothing if can't move
	if !canMove:
		return
	
	# determine hasLanded
	if is_on_floor():
		hasLanded = true

	# handle dash + associated animation/sound
	if event is InputEventMouseButton and dashDelayTimer.is_stopped() and hasLanded: # on click
		print("dashing: " + String(hasLanded))
		
		# hasn't landed since dashing yet
		hasLanded = false

		# start timer
		dashDelayTimer.start(dashDelay)

		# play sound effect
		sfx.set_stream(dashSound)
		sfx.play()

		# get local mouse direction, calculate motion
		var mouse_direction = get_local_mouse_position().normalized()
		motion = Vector2(mouse_direction.x, mouse_direction.y) * DASH_SPEED
		print("Mouse position:\t" + String(get_global_mouse_position()))

		var t = get_physics_process_delta_time()

		# used for animation facing
		if mouse_direction.x > sprite.position.x: # dashing right
			facingRight = true
			sprite.scale.x = 1
		elif mouse_direction.x < sprite.position.y: # dashing left
			facingRight = false
			sprite.scale.x = -1

		# animate
		anim.play("Dash")

func _physics_process(delta):
	# lock all movement if canMove == false
	if !canMove:
		return
	
	# if dashing
	if anim.current_animation == "Dash":
		# apply movement and stop
		motion = move_and_slide(motion, UP)
		return
	
	# handle rolling
	if Input.is_action_pressed("roll") and rollDelayTimer.is_stopped() and is_on_floor():
		# play sfx
		sfx.set_stream(rollSound)
		sfx.play()
		#play animation
		anim.play("Roll")
		
		#start timer
		rollDelayTimer.start(rollDelay)
		
		if facingRight:
			motion.x = ROLL_SPEED
		else:
			motion.x = -ROLL_SPEED
		motion = move_and_slide(motion, UP)
		return
	elif anim.current_animation != "Roll": # limit speed if not rolling
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
	
	# falling physics
	motion.y += GRAVITY
	if motion.y > MAX_FALL_SPEED:
		motion.y = MAX_FALL_SPEED

	# used for animation facing
	if facingRight == true:
		sprite.scale.x = 1
	else:
		sprite.scale.x = -1

	# horizontal movement
	if Input.is_action_pressed("right") and anim.current_animation != "Roll": # input right and not rolling
		# Accelerate and update facingRight
		motion.x += ACCELERATION
		facingRight = true
		if is_on_floor(): # animate and play sfx
			anim.play("Run")
			if not (sfx.playing and sfx.stream == runSound):
				sfx.set_stream(runSound)
				sfx.play()
	elif Input.is_action_pressed("left") and anim.current_animation != "Roll": # input left and not rolling
		# Decelerate and update facingRight
		motion.x -= ACCELERATION
		facingRight = false
		if is_on_floor(): # animate and play sfx
			anim.play("Run")
			if not (sfx.playing and sfx.stream == runSound):
				sfx.set_stream(runSound)
				sfx.play()
	
	elif anim.current_animation != "Roll": # slow down if not running and not rolling
		motion.x = lerp(motion.x, 0, 0.2)
		if is_on_floor():
			anim.play("Idle")
	
	# limit speed if sneaking
	if Input.is_action_pressed("sneak") and anim.current_animation != "Roll":
		motion.x = clamp(motion.x, -MAX_SPEED/3, MAX_SPEED/3)
	
	# jumping
	if is_on_floor(): # can only jump if on floor
		falling = false
		if Input.is_action_pressed("jump"): # jump and play sfx
			motion.y = -JUMP_FORCE
			sfx.set_stream(jumpSound)
			sfx.play()
	else: # is in air, animate
		if motion.y < 0:
			anim.play("Jump")
		elif (motion.y > 0 && !falling):
			anim.play("Fall")
			falling = true

	# apply movement
	motion = move_and_slide(motion, UP)

func freeze(playIdle:bool = true):
	anim.play("Idle")
	canMove = false
func unfreeze():
	canMove = true
