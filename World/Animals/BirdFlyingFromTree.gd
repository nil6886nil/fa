extends Node2D

const SPEED: int = 160
var fly_position

func _ready():
	randomize()
	Images.BirdVariations.shuffle()
	$AnimatedSprite.frames = Images.BirdVariations[0]
	set_direction()


func set_direction():
	var tempPos = fly_position - position
	if tempPos.x < 0:
		$AnimatedSprite.flip_h = true
	if abs(tempPos.x) > abs(tempPos.y):
		$AnimatedSprite.play("fly side")
	elif tempPos.y < 0:
		$AnimatedSprite.play("fly up")
	else: 
		$AnimatedSprite.play("fly down")


func _physics_process(delta):
	position = position.move_toward(fly_position, delta * SPEED)
	if position == fly_position:
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
