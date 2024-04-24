extends Node2D

@export var player: Player
@export var fireball_scene: PackedScene = preload("res://Player/FireballShield/Fireball.tscn")
@export var distance_from_player: float = 35
@export var number_of_fireballs: int = 8
@export var fireball_rotation_speed: float = 2.5

func _ready():
	assert(player, "Player must be set.")
	
	var degree_separation: float = 360.0 / number_of_fireballs
	print(degree_separation)
	
	for i in range(number_of_fireballs):
		var fireball = fireball_scene.instantiate()
		
		add_child(fireball)
		
		fireball.get_child(0).position.x += distance_from_player
		fireball.rotation_degrees += i * degree_separation

func _process(delta: float):
	rotation += fireball_rotation_speed * delta
