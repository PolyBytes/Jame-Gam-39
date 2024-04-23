extends Node

var scene_root
var flying_eye: PackedScene = preload("res://Enemies/Flying-Eye/FlyingEye.tscn")

var spawn_range: int = 500
var enemy_count: int = 1

func _ready():
	scene_root = get_tree().get_first_node_in_group("level")
	spawn_wave()

func _process(_delta):
	if Input.is_action_just_pressed("dodge_roll"):
		spawn_wave()

func spawn_wave():
	for i in range(enemy_count):
		var enemy = flying_eye.instantiate()
		
		enemy.position.x = randi_range(-spawn_range, spawn_range)
		enemy.position.y = randi_range(-spawn_range, spawn_range)
		
		scene_root.add_child(enemy)
