class_name FireRose extends Area2D

@export var sound_fade_time_seconds: float = 1
@export var sprite_fade_time_seconds: float = 0.5

func _on_body_entered(body):
	if body is Player:
		body.fire_rose_picked_up.emit()
		SpawnManager.show_health_sacrifice(position, body.health_sacrifice_per_rose)
		
		$CPUParticles2D.emitting = false
		
		var fade_tween = get_tree().create_tween()
		fade_tween.parallel().tween_property($FireRoseGlimmer, "volume_db", -35, sound_fade_time_seconds)
		fade_tween.parallel().tween_property($Sprite2D, "modulate:a", 0, sprite_fade_time_seconds)
		fade_tween.tween_callback(queue_free)
