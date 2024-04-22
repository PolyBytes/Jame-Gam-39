extends Control

var target_health_percentage: float = 1
var current_health_percentage: float = 1
var health_lerp_speed: float = 2

func _ready():
	%HealthBauble.material.set_shader_parameter("fill_per", current_health_percentage)

func _process(delta):
	if not is_equal_approx(current_health_percentage, target_health_percentage):
		current_health_percentage = lerpf(current_health_percentage, target_health_percentage, health_lerp_speed * delta)
		%HealthBauble.material.set_shader_parameter("fill_per", current_health_percentage)
	else:
		set_process(false)

func _on_player_health_changed(new_health, max_health):
	target_health_percentage = new_health as float / max_health
	set_process(true)
