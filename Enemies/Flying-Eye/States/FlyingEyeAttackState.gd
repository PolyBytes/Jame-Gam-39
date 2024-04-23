class_name FlyingEyeAttackState extends AttackState

@export_group("Transitionable States")
@export var follow_state: FlyingEyeFollowState

@export var charge_speed: float = 200
@export var time_seconds_before_charging: float = 0.2
@export var attack_end_distance: float = 250

var parent_enemy: FlyingEyeEnemy
var target_vector: Vector2
var target_player_position: Vector2

func _ready():
	super()
	assert(follow_state, "Follow State must be set.")

func enter_state():
	parent_enemy = enemy_state_machine.parent_enemy
	var target_player: Player = enemy_state_machine.parent_enemy.target_player
	
	if not target_player or not parent_enemy:
		return follow_state
	
	parent_enemy.velocity = Vector2.ZERO
	
	await get_tree().create_timer(time_seconds_before_charging).timeout
	
	target_player_position = target_player.position
	target_vector = parent_enemy.position.direction_to(target_player_position)
	parent_enemy.velocity = target_vector * charge_speed
	parent_enemy.look_direction = sign(target_vector.x)

func physics_process_state(delta: float) -> EnemyState:
	super(delta)
	
	parent_enemy.position += parent_enemy.velocity * delta
	
	if parent_enemy.position.distance_to(target_player_position) >= attack_end_distance:
		return follow_state
	
	return null
