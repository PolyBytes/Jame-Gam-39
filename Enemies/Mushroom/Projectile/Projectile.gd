class_name MushroomEnemyProjectile extends Area2D

@export var projectile_damage: int = 10
@export var movement_speed: float = 100

var attack_can_hit: bool = true

var target_vector: Vector2:
	set(value):
		target_vector = value
		$LifetimeTimer.start()
		set_process(true)

func _ready():
	set_process(false)

func _process(delta):
	if attack_can_hit:
		position += target_vector * movement_speed * delta
	
	var overlapping_bodies = get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if not body is Player:
			continue
		
		if not attack_can_hit:
			continue
		
		attack_can_hit = false
		$AnimationPlayer.play("explode")
		body.take_damage(projectile_damage)
		SpawnManager.show_health_sacrifice(body.position, projectile_damage)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "explode":
		queue_free()

func _on_lifetime_timer_timeout():
	attack_can_hit = false
	$AnimationPlayer.play("explode")
