class_name FlyingEyeSlainState extends SlainState

@export_group("State Properties")
@export var enemy_despawn_time_seconds: float = 3

var current_enemy_despawn_time_seconds: float
var despawning: bool = false
var parent_enemy: FlyingEyeEnemy

func enter_state():
	super()
	current_enemy_despawn_time_seconds = enemy_despawn_time_seconds
	
	parent_enemy = enemy_state_machine.parent_enemy

func process_state(delta: float) -> EnemyState:
	if current_enemy_despawn_time_seconds > 0:
		current_enemy_despawn_time_seconds -= delta
		return null
	
	if not despawning:
		despawning = true
		parent_enemy.queue_free()
	
	return null
