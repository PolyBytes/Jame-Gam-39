class_name Enemy extends Area2D

signal stunned

@export var attack_damage: float = 5
@export var is_alive: bool = true
@export var max_health: int = 10
@export var score_to_award: int = 20
@export var health_to_award: int = 1
@export var health_award_chance: float = 0.5
var health: int = max_health
var target_player: CharacterBody2D
var is_stunned: bool = false

func _ready():
	collision_layer = 0
	set_collision_layer_value(3, true)
	collision_mask = 0
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)

func take_damage(damage_amount: int):
	health = clampi(health - damage_amount, 0, max_health)
	
	if health == 0:
		is_alive = false
		SpawnManager.enemy_slain.emit()
