extends Node

signal prepare_for_next_wave(next_wave_number: int)


var enemy_root_node: Node2D
var player: Player

var reward_indicators: Node2D
var reward_health: PackedScene = preload("res://RewardIndicators/RewardHealth/RewardHealth.tscn")
var reward_score: PackedScene = preload("res://RewardIndicators/RewardScore/RewardScore.tscn")

var flying_eye: PackedScene = preload("res://Enemies/FlyingEye/FlyingEye.tscn")

class Wave:
	var number_of_flying_eyes: int
	
	func _init(p_number_of_flying_eyes: int):
		self.number_of_flying_eyes = p_number_of_flying_eyes

var wave_list: Array[Wave] = []
var current_wave_count: int = 0
var current_wave_list_lap: int = 0
var number_of_waves_per_lap: int
var enemy_spawn_locations: Array[Vector2] = []

func _ready():
	wave_list.append(Wave.new(5))
	wave_list.append(Wave.new(10))
	wave_list.append(Wave.new(15))
	wave_list.append(Wave.new(20))
	wave_list.append(Wave.new(25))
	
	for spawn_location in get_tree().get_first_node_in_group("enemy_spawn_locations").get_children():
		enemy_spawn_locations.append(spawn_location.position)
	
	number_of_waves_per_lap = wave_list.size()
	enemy_root_node = get_tree().get_first_node_in_group("enemy_root_node")
	player = get_tree().get_first_node_in_group("player")
	reward_indicators = get_tree().get_first_node_in_group("reward_indicators")
	
	enemy_root_node.child_exiting_tree.connect(_on_enemy_slain)
	
	await player.ready
	prepare_for_next_wave.emit(1)

func spawn_wave():
	var current_wave: Wave = wave_list[current_wave_count]
	var number_of_flying_eyes: int = (current_wave.number_of_flying_eyes * current_wave_list_lap) + current_wave.number_of_flying_eyes
	
	for i in range(number_of_flying_eyes):
		var enemy = flying_eye.instantiate()
		enemy_root_node.add_child(enemy)
		enemy.position = enemy_spawn_locations.pick_random()

func _on_enemy_slain(_enemy: Node2D):
	# You have to subtract 1 because the get_child_count() method has not changed count yet.
	if enemy_root_node.get_child_count() - 1 != 0:
		return
	
	current_wave_count += 1
	
	if current_wave_count > number_of_waves_per_lap - 1:
		current_wave_list_lap += 1
		current_wave_count = 0
	
	var next_wave_number: int = (current_wave_list_lap * number_of_waves_per_lap) + current_wave_count + 1
	prepare_for_next_wave.emit(next_wave_number)

func _on_prepare_for_next_wave(_next_wave_number: int):
	$WaveSpawnDelay.start()

func _on_wave_spawn_delay_timeout():
	spawn_wave()

func show_health_reward(position: Vector2, amount: int):
	var health_reward = reward_health.instantiate()
	
	reward_indicators.add_child(health_reward)
	health_reward.position = position
	health_reward.position.y -= 5
	health_reward.amount = amount

func show_score_reward(position: Vector2, amount: int):
	var score_reward = reward_score.instantiate()
	
	reward_indicators.add_child(score_reward)
	score_reward.position = position
	score_reward.amount = amount
