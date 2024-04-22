extends Control

var health_bar_width: int

func _ready():
	health_bar_width = %HealthValue.size.x

func _on_player_health_changed(new_health, max_health):
	%HealthValue.size.x = (new_health as float / max_health) * health_bar_width
