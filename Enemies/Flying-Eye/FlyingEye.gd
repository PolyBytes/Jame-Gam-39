extends Enemy

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var attack_cooldown: Timer = $AttackCooldownTimer

@export var attack_can_hit: bool = false
var attack_distance: float = 23

var too_close_distance: float = 20
var min_sprite_orientation_distance: float = 0
var velocity: Vector2 = Vector2.ZERO
var target_player: CharacterBody2D
var distance_to_target: float

func _ready():
	target_player = get_tree().get_first_node_in_group("player")
	animation_state.travel("idle")

func _process(delta):
	if is_alive:
		handle_player_targeting(delta)
		handle_attacking()
	elif animation_state.get_current_node() != "death":
		animation_state.travel("death")

func handle_player_targeting(delta: float):
	if not target_player:
		return
	
	var movement_direction: Vector2 = position.direction_to(target_player.position)
	distance_to_target = position.distance_to(target_player.position)
	
	if distance_to_target > min_sprite_orientation_distance:
		if target_player.is_slain:
			$Sprite2D.flip_h = false if movement_direction.x < 0 else true
		else:
			$Sprite2D.flip_h = true if movement_direction.x < 0 else false
	
	if animation_state.get_current_node() == "idle":
		velocity = movement_direction * movement_speed * delta
		
		if target_player.is_slain:
			position -= velocity
		else:
			if distance_to_target > attack_distance:
				position += velocity
			elif distance_to_target < too_close_distance:
				position -= velocity

func handle_attacking():
	if distance_to_target <= attack_distance:
		if attack_cooldown.time_left == 0:
			attack_cooldown.start()
			animation_state.travel("attack")
	
	if attack_can_hit:
		if overlaps_body(target_player):
			target_player.take_damage(attack_damage)
			attack_can_hit = false

func take_damage(damage_amount: int):
	if not is_alive:
		return
	
	super(damage_amount)
	animation_state.travel("take_damage")

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "death":
		await get_tree().create_timer(3).timeout
		queue_free()
