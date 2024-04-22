extends Node

var scene_root
var flying_eye: PackedScene = preload("res://Enemies/Flying-Eye/FlyingEye.tscn")

func _ready():
	scene_root = get_tree().root.get_child(0)
	spawn_wave()

func spawn_wave():
	for i in range(5):
		var enemy = flying_eye.instantiate()
		
		enemy.position.x = randi_range(-200, 200)
		enemy.position.y = randi_range(-200, 200)
		
		scene_root.add_child(enemy)
