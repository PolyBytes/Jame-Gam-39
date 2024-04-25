class_name FlyingEyeStunnedState extends StunnedState

@export_group("Transitionable States")
@export var follow_state: FlyingEyeFollowState
@export var slain_state: FlyingEyeSlainState

@export_group("State Properties")
@export var stun_time_seconds: float = 1
@export var knockback_velocity: float = 50

var current_stun_time_seconds: float
var stun_started: bool
var parent_enemy: FlyingEyeEnemy

func _ready():
	super()
	assert(follow_state, "Follow State must be set.")
	assert(slain_state, "Slain State must be set.")
	
	parent_enemy = enemy_state_machine.parent_enemy

func enter_state():
	current_stun_time_seconds = stun_time_seconds
	stun_started = false
	parent_enemy.monitoring = false

func process_state(delta: float) -> EnemyState:
	if not parent_enemy.is_alive:
		return slain_state
	elif not stun_started:
		stun_started = true
		var target_player: Player = enemy_state_machine.parent_enemy.target_player
		var knockback_direction = -parent_enemy.position.direction_to(target_player.position)
		parent_enemy.velocity = knockback_direction * knockback_velocity
	elif current_stun_time_seconds > 0:
		current_stun_time_seconds -= delta
		parent_enemy.position += parent_enemy.velocity * delta
	else:
		return follow_state
	
	return null

func leave_state():
	parent_enemy.is_stunned = false
	parent_enemy.monitoring = true
