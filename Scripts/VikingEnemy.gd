extends KinematicBody2D

# Constants for sight arc
const THETA = 0.523599 # 30 degrees
const DISTANCE = 200

# Constants for movement
const UP = Vector2.UP
const GRAVITY = 20
const MAX_SPEED = 220
const ACCELERATION = 15

# variables for movement
var motion = Vector2()
var facingRight = true
var canMove = true

onready var player := $"../Player"

func _process(delta):
	if canSee(player):
		print("can see")
		approach(player)
	else:
		print("can't see")
		patrol()

func canSee(target):
	return inVisionArc(target) && clearLineOfSight(target)

func inVisionArc(target):
	var angleToTarget = get_angle_to(target.position) #approximate in degrees
	var angleCheck
	var distanceCheck
	
	# check angles
	if facingRight:
		angleCheck = (angleToTarget < THETA and angleToTarget > -THETA)
	else: #facing left
		angleCheck = (angleToTarget > (PI - THETA) or angleToTarget < (-PI + THETA) )
	
	# check distance
	distanceCheck = abs(target.position.x - position.x) < DISTANCE
	return angleCheck and distanceCheck

func clearLineOfSight(target):
	$RayCast2D.force_raycast_update()
	$RayCast2D.set_cast_to(player.position)
	return !$RayCast2D.is_colliding()

# approach and attack target
func approach(target):
	print("approaching")
	# limit max speed
	motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
	# apply  gravity
	motion.y += GRAVITY
	# horizontal movement
	if target.position.x > position.x and $AnimationPlayer.current_animation != "Attack": # input right and not rolling
		# Accelerate and update facingRight
		motion.x += ACCELERATION
		facingRight = true
		if is_on_floor(): # animate and play sfx
			$AnimationPlayer.play("Run")
#			if not (sfx.playing and sfx.stream == runSound):
#				sfx.set_stream(runSound)
#				sfx.play()
	elif target.position.x < position.x and $AnimationPlayer.current_animation != "Attack": # input left and not rolling
		# Decelerate and update facingRight
		motion.x -= ACCELERATION
		facingRight = false
		if is_on_floor(): # animate and play sfx
			$AnimationPlayer.play("Run")
#			if not (sfx.playing and sfx.stream == runSound):
#				sfx.set_stream(runSound)
#				sfx.play()
	# apply movement
	motion = move_and_slide(motion, UP)

# default behavior when enemy is not in sight
func patrol():
	$AnimationPlayer.play("Idle")
	if $Timer.is_stopped():
		$Timer.start()
		turnAround()

func turnAround():
	facingRight = !facingRight
	$Sprite.flip_h = !facingRight
	$RayCast2D.rotation_degrees = 270 if facingRight else 90

func die():
	$AnimationPlayer.play("Death")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Death":
		queue_free()
