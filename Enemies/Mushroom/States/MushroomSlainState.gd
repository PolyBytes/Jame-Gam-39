class_name MushroomSlainState extends SlainState

@export_group("State Properties")
@export var enemy_despawn_time_seconds: float = 3

var current_enemy_despawn_time_seconds: float
var despawning: bool = false
var parent_enemy: MushroomEnemy

func enter_state():
	super()
	current_enemy_despawn_time_seconds = enemy_despawn_time_seconds
	parent_enemy = enemy_state_machine.parent_enemy
	
	parent_enemy.target_player.score += parent_enemy.score_to_award
	SpawnManager.show_score_reward(parent_enemy.position, parent_enemy.score_to_award)
	
	if randf_range(0, 1) <= parent_enemy.health_award_chance:
		parent_enemy.target_player.heal(parent_enemy.health_to_award)
		SpawnManager.show_health_reward(parent_enemy.position, parent_enemy.health_to_award)

func process_state(delta: float) -> EnemyState:
	if current_enemy_despawn_time_seconds > 0:
		current_enemy_despawn_time_seconds -= delta
		return null
	
	if not despawning:
		despawning = true
		parent_enemy.queue_free()
	
	return null
