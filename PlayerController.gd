extends KinematicBody2D

# constants for player movement
const UP = Vector2.UP
const GRAVITY = 20
const MAX_FALL_SPEED = 200
const MAX_SPEED = 200
const JUMP_FORCE = 400
const ACCELERATION = 15
const DASH_SPEED = 400
const DASH_LENGTH = 0.1

# variables for motion and animation
var motion = Vector2()
var facingRight = true
var falling = false
var hasLanded = true
var dashing = false

# variables for audio handling
var played = false

# onready references to child nodes
onready var sprite := $Sprite
onready var slashSprite := $Slash
onready var anim := $AnimationPlayer
onready var dashDelayTimer := $DashDelayTimer

export var dashDelay: float = 0.5

func _physics_process(delta):
	# falling physics
	motion.y += GRAVITY
	if motion.y > MAX_FALL_SPEED:
		motion.y = MAX_FALL_SPEED
	
	# determine vars used for dashing
	if is_on_floor():
		hasLanded = true
	dashing = false
	
	# used for animation facing
	if facingRight == true:
		sprite.scale.x = 1
	else:
		sprite.scale.x = -1
	
	# handle dashing
	if Input.is_action_just_pressed("Dash") and dashDelayTimer.is_stopped() and hasLanded: # on click
		# hasn't landed since dashing yet
		print("Dashing")
		hasLanded = false
		dashing = true
		
		# start timer
		dashDelayTimer.start(dashDelay)

		# play sound effect
		$AudioStreamPlayer2D.play()

		# get local mouse direction, calculate motion
		var mouse_direction = get_local_mouse_position().normalized()
		motion = Vector2(mouse_direction.x, mouse_direction.y) * MAX_SPEED * 10
		print("Mouse position:\t" + String(get_viewport().get_mouse_position()))
		print("Global Transform:\t\t\t" + String(sprite.position))

		# used for animation facing
		if mouse_direction.x > sprite.position.x: # dashing right
			facingRight = true
			sprite.scale.x = 1
		elif mouse_direction.x < sprite.position.y: # dashing left
			facingRight = false
			sprite.scale.x = -1

		# animate
		anim.play("Dash")
	
	# horizontal movement
	if Input.is_action_pressed("right"):
		motion.x += ACCELERATION
		facingRight = true
		if is_on_floor() && anim.current_animation != "Dash":
			anim.play("Run")
	elif Input.is_action_pressed("left"):
		motion.x -= ACCELERATION
		facingRight = false
		if is_on_floor() && anim.current_animation != "Dash":
			anim.play("Run")
	elif !dashing: # slow down if not running
		motion.x = lerp(motion.x, 0, 0.2)
		if is_on_floor() && anim.current_animation != "Dash":
			anim.play("Idle")
	
	# limit to max speed if not dashing
	if hasLanded:
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		#print(motion.x)
		pass
	else:
		motion.x = clamp(motion.x, -DASH_SPEED, DASH_SPEED)
		motion.y = clamp(motion.y, -DASH_SPEED, DASH_SPEED)
	
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

#func _input(event):
#	# determine hasLanded
#	if is_on_floor():
#		hasLanded = true
#
#	# handle dash + associated animation
#	if event is InputEventMouseButton and dashDelayTimer.is_stopped() and hasLanded: # on click
#		# hasn't landed since dashing yet
#		print("Dashing")
#		hasLanded = false
#
#		# start timer
#		dashDelayTimer.start(dashDelay)
#
#		# play sound effect
#		$AudioStreamPlayer2D.play()
#
#		# get local mouse direction, calculate motion
#		var mouse_direction = get_local_mouse_position().normalized()
#		motion = Vector2(mouse_direction.x, mouse_direction.y) * MAX_SPEED/2
#		print("Mouse position:\t" + String(get_viewport().get_mouse_position()))
#		print("Global Transform:\t\t\t" + String(sprite.position))
#
#		# used for animation facing
#		if mouse_direction.x > sprite.position.x: # dashing right
#			facingRight = true
#			sprite.scale.x = 1
#		elif mouse_direction.x < sprite.position.y: # dashing left
#			facingRight = false
#			sprite.scale.x = -1
#
#		# animate
#		anim.play("Dash")
#
#		# apply movement
#		move_and_collide(motion)
