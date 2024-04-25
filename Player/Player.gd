class_name Player extends CharacterBody2D

signal health_changed(new_health: int, max_health: int)
signal score_changed(new_score: int)

signal vision_rose_picked_up
signal haste_rose_picked_up
signal fire_rose_picked_up

const ACCELERATION = 1000.0

@export var max_movement_velocity: float = 100

@export_category("Screen Shake Properties")
@export var SHAKE_STRENGTH: float = 60.0
@export var SHAKE_DECAY_RATE: float = 5.0

@export_category("Attack Properties")
@export var sword_attack_damage: int = 4

@export_category("Power Up Properties")
@export var score_increase_per_rose: int = 150
@export var health_sacrifice_per_rose: int = 15
@export var vision_rose_vision_increase_multiplier: float = 2.5
@export var vision_rose_vision_change_time_seconds: float = 2
@export var haste_rose_max_movement_velocity_multiplier: float = 1.5
@export var haste_rose_speed_change_time_seconds: float = 2
@export var haste_rose_attack_speed_multiplier: float = 2
@export var fire_rose_attack_damage: int = 5
@export var fire_rose_spin_up_time_seconds: float = 2

@export_category("Variables Changed By Animation (Do Not Change)")
@export var sword_attack_can_hit: bool = false

@onready var camera = $Camera2D
@onready var rand = RandomNumberGenerator.new()
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

var is_slain: bool = false
var max_health: int = 100
var health: int = max_health
var shake_strength: float = 0.0

var current_max_movement_velocity: float = max_movement_velocity
var current_attack_speed_multiplier: float = 1

var score: int = 0:
	set(new_score):
		score = new_score
		%ScoreboardIncrease.play()
		score_changed.emit(new_score)

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
	
	$AnimationTree.set("parameters/attack/TimeScale/scale", current_attack_speed_multiplier)
	$AnimationTree.set("parameters/run/TimeScale/scale", (velocity.length() / max_movement_velocity))

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
	
	if velocity.length() > current_max_movement_velocity:
		velocity = velocity.limit_length(current_max_movement_velocity)

func handle_animation_states():
	if is_slain:
		animation_state.travel("death")
		return
	
	if Input.is_action_pressed("attack_primary"):
		if animation_state.get_current_node() != "attack":
			animation_state.travel("attack")
			apply_shake()
			%SwordSwing.play()
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

func heal(heal_amount: int):
	health = clampi(health + heal_amount, 0, max_health)
	health_changed.emit(health, max_health)

func handle_attacking():
	if not sword_attack_can_hit:
		return
	
	var hit_registered: bool = false
	
	for enemy in %AttackArea2D.get_overlapping_areas():
		if not enemy is Enemy:
			continue
		
		if not hit_registered and enemy.is_alive:
			hit_registered = true
			%SwordHit.play()
		
		enemy.take_damage(sword_attack_damage)
	
	sword_attack_can_hit = false

func _on_vision_rose_picked_up():
	score += score_increase_per_rose
	take_damage(health_sacrifice_per_rose)
	%VisionRosePickedUp.play()
	%VisionRosePowerUpTimer.start()
	
	var vision_tween = get_tree().create_tween()
	vision_tween.tween_property(%Vision, "texture_scale", vision_rose_vision_increase_multiplier, vision_rose_vision_change_time_seconds)

func _on_vision_rose_power_up_timer_timeout():
	var vision_tween = get_tree().create_tween()
	vision_tween.tween_property(%Vision, "texture_scale", 1, vision_rose_vision_change_time_seconds)

func _on_haste_rose_picked_up():
	score += score_increase_per_rose
	take_damage(health_sacrifice_per_rose)
	%HasteRosePickedUp.play()
	%HasteRosePowerUpTimer.start()
	
	current_attack_speed_multiplier = haste_rose_attack_speed_multiplier
	
	var haste_tween = get_tree().create_tween()
	haste_tween.tween_property(self, "current_max_movement_velocity", max_movement_velocity * haste_rose_max_movement_velocity_multiplier, haste_rose_speed_change_time_seconds)

func _on_haste_rose_power_up_timer_timeout():
	current_attack_speed_multiplier = 1
	
	var haste_tween = get_tree().create_tween()
	haste_tween.tween_property(self, "current_max_movement_velocity", max_movement_velocity, haste_rose_speed_change_time_seconds)

func _on_fire_rose_picked_up():
	score += score_increase_per_rose
	take_damage(health_sacrifice_per_rose)
	%FireRosePickedUp.play()
	%FireRosePowerUpTimer.start()
	
	%FireballShield.monitoring = true
	
	var fire_tween = get_tree().create_tween()
	fire_tween.parallel().tween_property(%FireballShield, "modulate:a", 1, fire_rose_spin_up_time_seconds)
	fire_tween.parallel().tween_property(%FireballShield, "scale", Vector2.ONE, fire_rose_spin_up_time_seconds)

func _on_fire_rose_power_up_timer_timeout():
	var fire_tween = get_tree().create_tween()
	fire_tween.parallel().tween_property(%FireballShield, "modulate:a", 0, fire_rose_spin_up_time_seconds)
	fire_tween.parallel().tween_property(%FireballShield, "scale", Vector2.ZERO, fire_rose_spin_up_time_seconds)
	
	await fire_tween.finished
	
	%FireballShield.monitoring = false
