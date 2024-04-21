extends CharacterBody2D

var movement_speed: float = 1000
var target_player: CharacterBody2D

func _ready():
	target_player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not target_player:
		return
	
	var movement_angle: Vector2 = position.direction_to(target_player.position)
	
	velocity = movement_angle * movement_speed * delta
	move_and_slide()
