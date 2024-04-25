class_name MushroomFollowState extends FollowState

@export_group("Transitionable States")
@export var attack_state: MushroomAttackState
@export var stunned_state: MushroomStunnedState

@export_group("Required Nodes")
@export var attack_cooldown_timer: Timer

@export_group("State Properties")
@export var acceleration: float = 150
@export var max_velocity: float = 50
@export var max_attack_distance: float = 300
@export var min_attack_distance: float = 270

var parent_enemy: Enemy
var target_player: Player

func _ready():
	super()
	assert(attack_state, "Attack State must be set.")
	assert(stunned_state, "Stunned State must be set.")
	
	parent_enemy = enemy_state_machine.parent_enemy
	await parent_enemy.ready
	target_player = parent_enemy.target_player

func physics_process_state(delta: float) -> EnemyState:
	super(delta)
	parent_enemy.retreating = false
	
	if not target_player or not parent_enemy:
		return null
	
	if parent_enemy.is_stunned:
		return stunned_state
	
	var target_vector = parent_enemy.position.direction_to(target_player.position)
	parent_enemy.look_direction = sign(target_vector.x)
	
	var distance_to_target: float = parent_enemy.position.distance_to(target_player.position)
	
	if distance_to_target <= max_attack_distance and distance_to_target >= min_attack_distance:
		if attack_cooldown_timer.time_left == 0:
			return attack_state
	elif not parent_enemy.can_still_retreat:
		if distance_to_target > max_attack_distance:
			parent_enemy.velocity += target_vector * acceleration * delta
		elif attack_cooldown_timer.time_left == 0:
			return attack_state
	elif distance_to_target > max_attack_distance:
		parent_enemy.velocity += target_vector * acceleration * delta
	elif distance_to_target < min_attack_distance:
		if parent_enemy.can_still_retreat:
			parent_enemy.retreating = true
			parent_enemy.velocity -= target_vector * acceleration * delta
		else:
			parent_enemy.velocity = Vector2.ZERO
	
	if parent_enemy.velocity.length() > max_velocity:
		parent_enemy.velocity = parent_enemy.velocity.limit_length(max_velocity)
	
	parent_enemy.position += parent_enemy.velocity * delta
	
	return null
