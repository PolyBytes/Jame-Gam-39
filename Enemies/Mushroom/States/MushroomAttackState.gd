class_name MushroomAttackState extends AttackState

var attack_projectile: PackedScene = preload("res://Enemies/Mushroom/Projectile/Projectile.tscn")

@export_group("Transitionable States")
@export var follow_state: MushroomFollowState
@export var stunned_state: MushroomStunnedState

@export_group("Required Nodes")
@export var attack_cooldown_timer: Timer

var parent_enemy: MushroomEnemy
var target_player: Player

func _ready():
	super()
	assert(follow_state, "Follow State must be set.")
	assert(stunned_state, "Stunned State must be set.")
	
	parent_enemy = enemy_state_machine.parent_enemy
	await parent_enemy.ready
	target_player = parent_enemy.target_player

func enter_state():
	parent_enemy.attack_finished = false
	parent_enemy.velocity = Vector2.ZERO
	
	var target_vector = parent_enemy.position.direction_to(target_player.position)
	parent_enemy.look_direction = sign(target_vector.x)
	
	var projectile = attack_projectile.instantiate()
	
	SpawnManager.mushroom_projectiles_root_node.add_child(projectile)
	projectile.position = parent_enemy.position
	projectile.target_vector = target_vector

func process_state(_delta: float) -> EnemyState:
	if parent_enemy.attack_finished:
		return follow_state
	
	return null

func leave_state():
	attack_cooldown_timer.start()
