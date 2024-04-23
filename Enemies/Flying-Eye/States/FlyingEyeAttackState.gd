class_name FlyingEyeAttackState extends AttackState

@export_group("Transitionable States")
@export var follow_state: FlyingEyeFollowState
@export var stunned_state: FlyingEyeStunnedState

@export var charge_speed: float = 200
@export var time_seconds_before_charging: float = 0.2
@export var attack_end_distance: float = 250

var parent_enemy: FlyingEyeEnemy
var target_player: Player
var target_vector: Vector2
var target_player_position: Vector2
var stunned: bool
var attack_can_hit: bool

func _ready():
	super()
	assert(follow_state, "Follow State must be set.")
	assert(stunned_state, "Stunned State must be set.")

func enter_state():
	super()
	stunned = false
	attack_can_hit = true
	
	parent_enemy = enemy_state_machine.parent_enemy
	target_player = enemy_state_machine.parent_enemy.target_player
	
	if not target_player or not parent_enemy:
		return follow_state
	
	if not parent_enemy.stunned.is_connected(_parent_enemy_stunned):
		parent_enemy.stunned.connect(_parent_enemy_stunned)
	
	parent_enemy.velocity = Vector2.ZERO
	
	await get_tree().create_timer(time_seconds_before_charging).timeout
	
	target_player_position = target_player.position
	target_vector = parent_enemy.position.direction_to(target_player_position)
	parent_enemy.velocity = target_vector * charge_speed
	parent_enemy.look_direction = sign(target_vector.x)

func physics_process_state(delta: float) -> EnemyState:
	super(delta)
	
	if stunned:
		return stunned_state
	
	parent_enemy.position += parent_enemy.velocity * delta
	
	if attack_can_hit:
		if parent_enemy.overlaps_body(target_player):
			target_player.take_damage(int(parent_enemy.attack_damage))
			attack_can_hit = false
	
	if parent_enemy.position.distance_to(target_player_position) >= attack_end_distance:
		return follow_state
	
	return null

func _parent_enemy_stunned():
	stunned = true
