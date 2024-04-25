class_name FlyingEyeFlankState extends FlankState

@export_group("Transitionable States")
@export var attack_state: FlyingEyeAttackState
@export var follow_state: FlyingEyeFollowState
@export var stunned_state: FlyingEyeStunnedState

@export_group("Required Nodes")
@export var attack_cooldown_timer: Timer

@export_group("State Properties")
@export var acceleration: float = 150
@export var max_velocity: float = 40
@export var too_far_distance: float = 100
@export var attack_cooldown_max_random_offset: float = 5

var attack_cooldown_default_wait_time: float
var random_flank_direction: int

var parent_enemy: Enemy

func _ready():
	super()
	assert(attack_state, "Attack State must be set.")
	assert(follow_state, "Follow State must be set.")
	assert(stunned_state, "Stunned State must be set.")
	assert(attack_cooldown_timer, "Attack Cooldown Timer must be set.")
	
	attack_cooldown_default_wait_time = attack_cooldown_timer.wait_time
	parent_enemy = enemy_state_machine.parent_enemy

func enter_state():
	super()
	
	if attack_cooldown_timer.time_left > 0:
		attack_cooldown_timer.start(attack_cooldown_timer.time_left)
	else:
		attack_cooldown_timer.start(attack_cooldown_default_wait_time + randf_range(0, attack_cooldown_max_random_offset))
	
	random_flank_direction = 1 if randi_range(0, 1) == 1 else -1

func physics_process_state(delta: float) -> EnemyState:
	super(delta)
	
	if parent_enemy.is_stunned:
		return stunned_state
	
	parent_enemy = enemy_state_machine.parent_enemy
	var target_player = enemy_state_machine.parent_enemy.target_player
	
	if not target_player or not parent_enemy:
		return null
	
	var target_vector = parent_enemy.position.direction_to(target_player.position)
	parent_enemy.look_direction = sign(target_vector.x)
	target_vector = target_vector.rotated(random_flank_direction * deg_to_rad(90))
	parent_enemy.velocity += target_vector * acceleration * delta
	
	if parent_enemy.velocity.length() > max_velocity:
		parent_enemy.velocity = parent_enemy.velocity.limit_length(max_velocity)

	parent_enemy.position += parent_enemy.velocity * delta
	
	var distance_to_target = parent_enemy.position.distance_to(target_player.position)
	
	if distance_to_target >= too_far_distance:
		return follow_state
	
	if attack_cooldown_timer.time_left == 0:
		return attack_state
	
	return null

func leave_state():
	attack_cooldown_timer.stop()
