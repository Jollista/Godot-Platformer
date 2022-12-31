extends KinematicBody2D

const UP = Vector2.UP
const GRAVITY = 20
const MAX_FALL_SPEED = 200
const MAX_SPEED = 150
const JUMP_FORCE = 400
const ACCELERATION = 10

var motion = Vector2()
var facingRight = true
var falling = false

func _ready():
	pass

func _physics_process(delta):
	# falling physics
	motion.y += GRAVITY
	if motion.y > MAX_FALL_SPEED:
		motion.y = MAX_FALL_SPEED
	
	if facingRight == true:
		$Sprite.scale.x = 1
	else:
		$Sprite.scale.x = -1
	
	motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
	
	# horizontal movement
	if Input.is_action_pressed("right"):
		motion.x += ACCELERATION
		facingRight = true
		if is_on_floor():
			$AnimationPlayer.play("Run")
	elif Input.is_action_pressed("left"):
		motion.x -= ACCELERATION
		facingRight = false
		if is_on_floor():
			$AnimationPlayer.play("Run")
	else:
		motion.x = lerp(motion.x, 0, 0.2)
		if is_on_floor():
			$AnimationPlayer.play("Idle")
	
	# jumping
	if is_on_floor(): # can only jump if on floor
		falling = false
		if Input.is_action_pressed("jump"):
			motion.y = -JUMP_FORCE
	else: # is in air
		if motion.y < 0:
			$AnimationPlayer.play("Jump")
		elif (motion.y > 0 && !falling):
			$AnimationPlayer.play("Fall")
			print(String(motion.y > 0 && !falling))
			falling = true
	
	#print("current_animation = " + String($AnimationPlayer.current_animation))
	
	motion = move_and_slide(motion, UP)
