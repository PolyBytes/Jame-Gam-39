extends Node

var vision_rose: PackedScene = preload("res://Pickups/VisionRose/VisionRose.tscn")
var haste_rose: PackedScene = preload("res://Pickups/HasteRose/HasteRose.tscn")
var fire_rose: PackedScene = preload("res://Pickups/FireRose/FireRose.tscn")

const MAX_ROSES_ACTIVE: int = 3
const MINIMUM_SPAWN_DISTANCE: float = 250

var vision_rose_spawn_chance: float = 0.8
var haste_rose_spawn_chance: float = 0.4
var fire_rose_spawn_chance: float = 0.15

var player: Player
var rose_root_node: Node2D
var rose_spawn_locations: Array[Vector2] = []
var number_of_active_roses: int = 0

func _ready():
	player = get_tree().get_first_node_in_group("player")
	rose_root_node = get_tree().get_first_node_in_group("rose_root_node")
	rose_root_node.child_entered_tree.connect(_on_rose_spawned)
	rose_root_node.child_exiting_tree.connect(_on_rose_picked_up)
	
	for location in get_tree().get_first_node_in_group("rose_spawn_locations").get_children():
		rose_spawn_locations.append(location.position)
	
	$RoseSpawnChanceTimer.start()

func get_random_spawn_location() -> Vector2:
	var spawn_location: Vector2
	
	while true:
		spawn_location = rose_spawn_locations.pick_random()
		var player_far_enough_away: bool = player.position.distance_to(spawn_location) >= MINIMUM_SPAWN_DISTANCE
		
		if not player_far_enough_away:
			continue
		
		var other_roses_far_enough_away: bool = true
		
		for rose in rose_root_node.get_children():
			if rose.position.distance_to(spawn_location) < MINIMUM_SPAWN_DISTANCE:
				other_roses_far_enough_away = false
				break
		
		if other_roses_far_enough_away:
			break
	
	return spawn_location

func _on_rose_spawned(_rose: Area2D):
	number_of_active_roses += 1

func _on_rose_picked_up(_rose: Area2D):
	number_of_active_roses -= 1

func _on_rose_spawn_chance_timer_timeout():
	$RoseSpawnChanceTimer.start()
	
	if not number_of_active_roses < MAX_ROSES_ACTIVE:
		return
	
	var chosen_rose: PackedScene
	var rose_roll = randf_range(0, 1)
	
	if rose_roll <= fire_rose_spawn_chance:
		chosen_rose = fire_rose
		#print("fire rose")
	elif rose_roll <= haste_rose_spawn_chance:
		chosen_rose = haste_rose
		#print("haste rose")
	elif rose_roll <= vision_rose_spawn_chance:
		chosen_rose = vision_rose
		#print("vision rose")
	
	if chosen_rose:
		var spawn_location = get_random_spawn_location()
		var rose = chosen_rose.instantiate()
		
		rose_root_node.add_child(rose)
		rose.position = spawn_location
