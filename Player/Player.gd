class_name Player extends CharacterBody2D

const MAX_VELOCITY = 100.0
const ACCELERATION = 1000.0

func _ready():
	$AnimatedSprite2D.play("Idle")

func _physics_process(delta):
	handle_input(delta)
	handle_animation_states()
	move_and_slide()

func handle_input(delta):
	var horizontal_direction: float = Input.get_axis("move_left", "move_right")
	var vertical_direction: float = Input.get_axis("move_up", "move_down")
	var input_vector: Vector2
	
	var current_frame_acceleration: float = ACCELERATION * delta
	
	if horizontal_direction:
		# Handle Sprite Horizontal Orientation
		$AnimatedSprite2D.flip_h = true if roundi(horizontal_direction) == -1 else false
		
		input_vector.x = horizontal_direction
	else:
		velocity.x = move_toward(velocity.x, 0, current_frame_acceleration)
	
	if vertical_direction:
		input_vector.y = vertical_direction
	else:
		velocity.y = move_toward(velocity.y, 0, ACCELERATION * delta)
	
	if input_vector.length() == 0:
		return
	
	velocity = velocity + (input_vector.normalized() * ACCELERATION * delta)
	
	if velocity.length() > MAX_VELOCITY:
		velocity = velocity.limit_length(MAX_VELOCITY)

func handle_animation_states():
	if velocity.length() > 0:
		$AnimatedSprite2D.play("Run")
	else:
		$AnimatedSprite2D.play("Idle")
