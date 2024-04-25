class_name FireballShield extends Area2D

@export var player: Player
@export var fireball_scene: PackedScene = preload("res://Player/FireballShield/Fireball.tscn")
@export var distance_from_player: float = 35
@export var number_of_fireballs: int = 8
@export var fireball_rotation_speed: float = 2.5
@export var fire_damage_check_time_seconds: float = 0.5

var current_fire_damage_check_time_seconds: float = fire_damage_check_time_seconds

func _ready():
	assert(player, "Player must be set.")
	
	$CollisionShape2D.shape.radius = distance_from_player
	
	modulate.a = 0
	scale = Vector2.ZERO
	monitoring = false
	
	var degree_separation: float = 360.0 / number_of_fireballs
	
	for i in range(number_of_fireballs):
		var fireball = fireball_scene.instantiate()
		
		add_child(fireball)
		
		fireball.get_child(0).position.x += distance_from_player
		fireball.rotation_degrees += i * degree_separation

func _process(delta: float):
	rotation += fireball_rotation_speed * delta
	
	if not monitoring:
		return
	
	if current_fire_damage_check_time_seconds > 0:
		current_fire_damage_check_time_seconds -= delta
		return
	
	current_fire_damage_check_time_seconds = fire_damage_check_time_seconds
	
	for area in get_overlapping_areas():
		if not area is Enemy:
			continue
		
		if not area.is_alive:
			continue
		
		if area.is_stunned:
			continue
		
		area.take_damage(player.fire_rose_attack_damage)
