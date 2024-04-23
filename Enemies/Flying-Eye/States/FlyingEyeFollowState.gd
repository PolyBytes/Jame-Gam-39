class_name FlyingEyeFollowState extends FollowState

@export_group("Transitionable States")
@export var flank_state: FlyingEyeFlankState

@export_group("State Properties")
@export var acceleration: float = 150
@export var max_velocity: float = 100
@export var max_flank_distance: float = 65
@export var min_flank_distance: float = 40
@export var flank_random_offset_range: float = 20
@export var max_velocity_random_offset_range: float = 50

var flank_random_offset: float
var max_velocity_random_offset: float

func _ready():
	super()
	assert(flank_state, "Flank State must be set.")

func enter_state():
	flank_random_offset = randf_range(-flank_random_offset_range, flank_random_offset_range)
	max_velocity_random_offset = randf_range(-max_velocity_random_offset_range, max_velocity_random_offset_range)

func physics_process_state(delta: float) -> EnemyState:
	super(delta)
	
	var parent_enemy = enemy_state_machine.parent_enemy
	var target_player = enemy_state_machine.parent_enemy.target_player
	
	if not target_player or not parent_enemy:
		return null
		
	var target_vector = parent_enemy.position.direction_to(target_player.position)
	parent_enemy.look_direction = sign(target_vector.x)
	parent_enemy.velocity += target_vector * acceleration * delta
	
	if parent_enemy.velocity.length() > (max_velocity + max_velocity_random_offset):
		parent_enemy.velocity = parent_enemy.velocity.limit_length(max_velocity)
	
	var distance_to_target: float = parent_enemy.position.distance_to(target_player.position)
	
	if distance_to_target > max_flank_distance + flank_random_offset:
		parent_enemy.position += parent_enemy.velocity * delta
	elif distance_to_target < min_flank_distance + flank_random_offset:
		parent_enemy.position -= parent_enemy.velocity * delta
	else:
		return flank_state
	
	return null
