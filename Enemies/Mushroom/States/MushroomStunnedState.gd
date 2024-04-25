class_name MushroomStunnedState extends StunnedState

@export_group("Transitionable States")
@export var follow_state: MushroomFollowState
@export var slain_state: MushroomSlainState

@export_group("State Properties")
@export var stun_time_seconds: float = 1

var current_stun_time_seconds: float
var parent_enemy: MushroomEnemy

func _ready():
	super()
	assert(follow_state, "Follow State must be set.")
	assert(slain_state, "Slain State must be set.")
	
	parent_enemy = enemy_state_machine.parent_enemy

func enter_state():
	current_stun_time_seconds = stun_time_seconds
	parent_enemy.monitoring = false
	parent_enemy.velocity = Vector2.ZERO

func process_state(delta: float) -> EnemyState:
	if not parent_enemy.is_alive:
		return slain_state
	elif current_stun_time_seconds > 0:
		current_stun_time_seconds -= delta
	else:
		return follow_state
	
	return null

func leave_state():
	parent_enemy.is_stunned = false
	parent_enemy.monitoring = true
