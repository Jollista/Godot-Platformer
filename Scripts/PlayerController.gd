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

# variables for audio handling
var played = false

# onready references to child nodes
onready var sprite := $Sprite
onready var anim := $AnimationPlayer
onready var dashDelayTimer := $DashDelayTimer
onready var rollDelayTimer := $RollDelayTimer

export var dashDelay: float = 0.5
export var rollDelay: float = 0.3

func _input(event):
	# determine hasLanded
	if is_on_floor():
		hasLanded = true

	# handle dash + associated animation
	if event is InputEventMouseButton and dashDelayTimer.is_stopped() and hasLanded: # on click
		# hasn't landed since dashing yet
		hasLanded = false

		# start timer
		dashDelayTimer.start(dashDelay)

		# play sound effect
		$DashSFX.play()

		# get local mouse direction, calculate motion
		var mouse_direction = get_local_mouse_position().normalized()
		motion = Vector2(mouse_direction.x, mouse_direction.y) * DASH_SPEED
		print("Mouse position:\t" + String(get_viewport().get_mouse_position()))
		print("Global Transform:\t\t\t" + String(sprite.position))

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

		# apply movement
		#move_and_collide(motion)

func _physics_process(delta):
	# if dashing
	if anim.current_animation == "Dash":
		# apply movement
		motion = move_and_slide(motion, UP)
		return
	
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
	if Input.is_action_pressed("right") and rollDelayTimer.is_stopped():
		motion.x += ACCELERATION
		facingRight = true
		if is_on_floor() && anim.current_animation != "Dash":
			anim.play("Run")
	elif Input.is_action_pressed("left") and rollDelayTimer.is_stopped():
		motion.x -= ACCELERATION
		facingRight = false
		if is_on_floor() && anim.current_animation != "Dash":
			anim.play("Run")
	elif rollDelayTimer.is_stopped(): # slow down if not running
		motion.x = lerp(motion.x, 0, 0.2)
		if is_on_floor() && anim.current_animation != "Dash":
			anim.play("Idle")

	# limit speed if sneaking
	if Input.is_action_pressed("sneak"):
		motion.x = clamp(motion.x, -MAX_SPEED/3, MAX_SPEED/3)
	# handle rolling
	elif Input.is_action_pressed("roll") and rollDelayTimer.is_stopped() and is_on_floor():
		$RollSFX.play()
		rollDelayTimer.start(rollDelay)
		if facingRight:
			motion.x = ROLL_SPEED
		else:
			motion.x = -ROLL_SPEED
		anim.play("Roll")
	elif rollDelayTimer.is_stopped(): # limit speed if not rolling
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
	#print(motion.x)

	# jumping
	if is_on_floor(): # can only jump if on floor
		falling = false
		if Input.is_action_pressed("jump") && anim.current_animation != "Dash":
			motion.y = -JUMP_FORCE
	else: # is in air
		if motion.y < 0 && anim.current_animation != "Dash":
			anim.play("Jump")
		elif (motion.y > 0 && !falling) && anim.current_animation != "Dash":
			anim.play("Fall")
			falling = true

	# apply movement
	motion = move_and_slide(motion, UP)
