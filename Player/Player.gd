class_name Player extends CharacterBody2D

const MAX_VELOCITY = 100.0
const ACCELERATION = 1000.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

var is_slain: bool = false
var is_rolling: bool = false

#func _ready():
	#$AnimatedSprite2D.play("Idle")

func _process(_delta):
	if Input.is_action_just_pressed("debug_testing_die"):
		is_slain = true
	elif Input.is_action_just_pressed("dodge_roll"):
		if not is_slain and animation_state.get_current_node() == "roll":
			is_rolling = true

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	if not is_slain:
		input_vector = handle_input()
	
	update_velocity(delta, input_vector)
	handle_animation_states()
	move_and_slide()

func handle_input() -> Vector2:
	var horizontal_direction: float = Input.get_axis("move_left", "move_right")
	var vertical_direction: float = Input.get_axis("move_up", "move_down")
	var input_vector: Vector2 = Vector2()
	
	if horizontal_direction:
		# Handle Sprite Horizontal Orientation
		$Sprite2D.flip_h = true if roundi(horizontal_direction) == -1 else false
		
		input_vector.x = horizontal_direction

	if vertical_direction:
		input_vector.y = vertical_direction
	
	return input_vector

func update_velocity(delta: float, input_vector: Vector2):
	var current_frame_acceleration: float = ACCELERATION * delta
	
	if is_equal_approx(input_vector.x, 0):
		velocity.x = move_toward(velocity.x, 0, current_frame_acceleration)
	
	if is_equal_approx(input_vector.y, 0):
		velocity.y = move_toward(velocity.y, 0, ACCELERATION * delta)
	
	if input_vector.length() == 0:
		return
	
	velocity = velocity + (input_vector.normalized() * ACCELERATION * delta)
	
	if velocity.length() > MAX_VELOCITY:
		velocity = velocity.limit_length(MAX_VELOCITY)

func handle_animation_states():
	if is_slain:
		animation_state.travel("death")
		return
	
	if is_rolling:
		is_rolling = false
		animation_state.travel("roll")

	if velocity.length() > 0:
		animation_state.travel("run")
	else:
		animation_state.travel("idle")
