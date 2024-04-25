class_name MushroomAttackState extends AttackState

@export_group("Transitionable States")
@export var follow_state: MushroomFollowState
@export var stunned_state: MushroomStunnedState

@export_group("Required Nodes")
@export var attack_cooldown_timer: Timer

func _ready():
	super()
	assert(follow_state, "Follow State must be set.")
	assert(stunned_state, "Stunned State must be set.")

func process_state(delta: float) -> EnemyState:
	return follow_state

func leave_state():
	attack_cooldown_timer.start()
