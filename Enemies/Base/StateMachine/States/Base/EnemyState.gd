class_name EnemyState extends Node

@export_group("Required Nodes")
@export var enemy_state_machine: EnemyStateMachine

func _ready():
	assert(enemy_state_machine, "Enemy State Machine must be set.")

func enter_state():
	pass

func process_state(_delta: float) -> EnemyState:
	return null

func physics_process_state(_delta: float) -> EnemyState:
	return null

func leave_state():
	pass
