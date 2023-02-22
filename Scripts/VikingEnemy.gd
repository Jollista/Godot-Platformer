extends KinematicBody2D

var facingRight = true
const THETA = 0.523599 # 30 degrees
const DISTANCE = 200

onready var player := $"../Player"

func _process(delta):
	if canSee(player):
		approach(player)
	else:
		patrol()

func canSee(target):
	if inVisionArc(target):
		print("enemy can see you")
		return true
	print("can't see")
	return false

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

# approach and attack target
func approach(target):
	pass

# default behavior when enemy is not in sight
func patrol():
	$AnimationPlayer.play("Idle")
	if $Timer.is_stopped():
		$Timer.start()
		turnAround()

func turnAround():
	facingRight = !facingRight
	$Sprite.flip_h = !facingRight

func die():
	$AnimationPlayer.play("Death")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Death":
		queue_free()
