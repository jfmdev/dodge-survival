extends Area2D
signal hit

export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.
var target = Vector2() # Variable to hold the clicked position.

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func start(pos):
	position = pos
	target = pos
	show()
	$CollisionShape2D.disabled = false

func _input(event):
	# Change the target whenever a touch event happens.
	if event is InputEventScreenTouch and event.pressed:
		target = event.position

func _process(delta):
	var velocity = Vector2()  # The player's movement vector.
	
	# Check for keyboard controls.
	var keyPressed = false
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
		keyPressed = true
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
		keyPressed = true
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
		keyPressed = true
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		keyPressed = true

	# Check for touch controls.
	if keyPressed:
		target = position
	elif position.distance_to(target) > 10:
		# Move towards the target and stop when close.
		velocity = target - position

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	if velocity.x != 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0

func _on_Player_body_entered(body):
	hide()  # Player disappears after being hit.
	emit_signal("hit")
	$CollisionShape2D.set_deferred("disabled", true)
