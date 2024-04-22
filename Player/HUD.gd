extends Control

var health_bar_percent: int

func _ready():
	health_bar_percent = %HealthValue.value

func _on_player_health_changed(new_health, max_health):
	%HealthValue.value = (new_health as float / max_health) * health_bar_percent
