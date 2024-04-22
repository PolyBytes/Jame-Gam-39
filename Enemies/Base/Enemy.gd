class_name Enemy extends Area2D

@export var attack_damage: float = 5
@export var movement_speed: float = 30
@export var is_alive: bool = true
@export var max_health: int = 10
var health: int = max_health

func take_damage(damage_amount: int):
	health = clampi(health - damage_amount, 0, max_health)
	
	if health == 0:
		is_alive = false
