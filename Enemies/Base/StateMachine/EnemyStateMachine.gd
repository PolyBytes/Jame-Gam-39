class_name EnemyStateMachine extends Node

signal state_changed(new_state: EnemyState)

@export_group("Required Nodes")
@export var parent_enemy: Enemy
@export var initial_state: EnemyState

var current_state: EnemyState

func _ready():
	assert(parent_enemy, "Parent Enemy must be set.")
	assert(initial_state, "Initial State must be set.")
	
	await parent_enemy.ready
	transition_state(initial_state)

func _process(delta):
	var new_state = current_state.process_state(delta)
	
	if new_state:
		transition_state(new_state)

func _physics_process(delta):
	var new_state = current_state.physics_process_state(delta)
	
	if new_state:
		transition_state(new_state)

func transition_state(new_state: EnemyState):
	if current_state:
		current_state.leave_state()
	
	current_state = new_state
	current_state.enter_state()
	state_changed.emit(current_state)
