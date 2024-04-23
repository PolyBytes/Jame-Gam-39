class_name Player extends CharacterBody2D

signal health_changed(new_health: int, max_health: int)

@export var SHAKE_STRENGTH: float = 60.0
@export var SHAKE_DECAY_RATE: float = 5.0

@onready var camera = $Camera2D
@onready var rand = RandomNumberGenerator.new()

var shake_strength: float = 0.0

const MAX_VELOCITY = 100.0
const ACCELERATION = 1000.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

@export var sword_attack_can_hit: bool = false
@export var sword_attack_damage: int = 4

var is_slain: bool = false
var max_health: int = 100
var health: int = max_health

func _ready():
	collision_layer = 0
	set_collision_layer_value(2, true)
	animation_state.travel("idle")

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	if not is_slain:
		input_vector = handle_input()
	
	update_velocity(delta, input_vector)
	handle_animation_states()
	handle_attacking()
	move_and_slide()

func _process(delta: float) -> void:
	shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	camera.offset = get_random_offset()
	
func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)

func apply_shake() -> void:
	shake_strength = SHAKE_STRENGTH

func handle_input() -> Vector2:
	var horizontal_direction: float = Input.get_axis("move_left", "move_right")
	var vertical_direction: float = Input.get_axis("move_up", "move_down")
	var input_vector: Vector2 = Vector2()
	
	if horizontal_direction:
		# Handle Sprite Horizontal Orientation
		if roundi(horizontal_direction) == -1:
			$Sprite2D.flip_h = true
			%SwordSwingCollisionPolygon.scale.x = -1
		else:
			$Sprite2D.flip_h = false
			%SwordSwingCollisionPolygon.scale.x = 1
		
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
	
	if animation_state.get_current_node() == "attack":
		velocity = Vector2.ZERO
		return
	
	velocity = velocity + (input_vector.normalized() * ACCELERATION * delta)
	
	if velocity.length() > MAX_VELOCITY:
		velocity = velocity.limit_length(MAX_VELOCITY)

func handle_animation_states():
	if is_slain:
		animation_state.travel("death")
		return
	
	if Input.is_action_just_pressed("attack_primary"):
		if animation_state.get_current_node() != "attack":
			animation_state.travel("attack")
			apply_shake()
			$SwordSwing.play()
			return

	if velocity.length() > 0:
		animation_state.travel("run")
	else:
		animation_state.travel("idle")

func take_damage(damage_amount: int):
	health = clampi(health - damage_amount, 0, max_health)
	health_changed.emit(health, max_health)
	apply_shake()
	
	if health == 0:
		is_slain = true

func handle_attacking():
	if not sword_attack_can_hit:
		return
	
	var hit_registered: bool = false
	
	for enemy in %AttackArea2D.get_overlapping_areas():
		if not enemy is Enemy:
			continue
		
		if not hit_registered and enemy.is_alive:
			hit_registered = true
			$SwordHit.play()
		
		enemy.take_damage(sword_attack_damage)
	
	sword_attack_can_hit = false
