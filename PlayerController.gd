extends KinematicBody2D

const UP = Vector2.UP
const GRAVITY = 20
const MAX_FALL_SPEED = 200
const MAX_SPEED = 200
const JUMP_FORCE = 400
const ACCELERATION = 15

var motion = Vector2()
var facingRight = true
var falling = false

onready var sprite := $Sprite
onready var anim := $AnimationPlayer
onready var dashDelayTimer := $DashDelayTimer

export var dashDelay: float = 0.5

func _ready():
	pass

func _physics_process(delta):
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
	else: # slow down if not running
		motion.x = lerp(motion.x, 0, 0.2)
		if is_on_floor() && anim.current_animation != "Dash":
			anim.play("Idle")
	# limit to max speed
	motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
	print(motion.x)
	
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

func _input(event):
	if event is InputEventMouseButton and dashDelayTimer.is_stopped(): # on click
		# start timer
		dashDelayTimer.start(dashDelay)
		
		var mouse_direction = get_local_mouse_position().normalized()
		motion = Vector2(MAX_SPEED/2 * mouse_direction.x, MAX_SPEED/2 * mouse_direction.y)
		print(get_viewport().get_mouse_position())
		
		# animate
		anim.play("Dash")
		
		# apply movement
		move_and_collide(motion)

