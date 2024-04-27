extends Control
#const level = preload("res://Levels/Main/Main.tscn")
@export var wave_announcer_fade_time_seconds: float = 2
@export var power_up_announcer_fade_time_seconds: float = 1

@export_group("Scoreboard Properties")
@export var zeros_to_pad_score: int = 8
@export var score_color: Color = Color("ffffff")
@export var zero_color: Color = Color("6d6d6d")

@export_group("Power Bar Timers")
@export var vision_rose_timer: Timer
@export var haste_rose_timer: Timer
@export var fire_rose_timer: Timer

var target_health_percentage: float = 1
var current_health_percentage: float = 1
var health_lerp_speed: float = 2

func _ready():
	assert(vision_rose_timer, "Vision Rose Timer must be set.")
	assert(haste_rose_timer, "Haste Rose Timer must be set.")
	assert(fire_rose_timer, "Fire Rose Timer must be set.")
	
	%HealthBauble.material.set_shader_parameter("fill_per", current_health_percentage)
	_on_player_score_changed(0)
	$WaveAnnouncer.modulate.a = 0
	$PowerUpAnnouncer.modulate.a = 0
	$PauseScreen.visible = false
	SpawnManager.prepare_for_next_wave.connect(_on_prepare_for_next_wave)
	PauseManager.pause_screen = $PauseScreen

func _process(delta):
	if not is_equal_approx(current_health_percentage, target_health_percentage):
		current_health_percentage = lerpf(current_health_percentage, target_health_percentage, health_lerp_speed * delta)
		%HealthBauble.material.set_shader_parameter("fill_per", current_health_percentage)
	
	if vision_rose_timer.time_left > 0:
		%VisionRosePowerBar.material.set_shader_parameter("percentage", (vision_rose_timer.time_left / vision_rose_timer.wait_time))
	
	if haste_rose_timer.time_left > 0:
		%HasteRosePowerBar.material.set_shader_parameter("percentage", (haste_rose_timer.time_left / haste_rose_timer.wait_time))
	
	if fire_rose_timer.time_left > 0:
		%FireRosePowerBar.material.set_shader_parameter("percentage", (fire_rose_timer.time_left / fire_rose_timer.wait_time))
	
	var number_of_enemies: int = SpawnManager.enemy_root_node.get_child_count()
	
	if number_of_enemies > 0:
		$EnemiesRemaining.text = "Enemies Remaining: " + str(number_of_enemies)
	else:
		$EnemiesRemaining.text = ""

func _on_player_health_changed(new_health, max_health):
	target_health_percentage = new_health as float / max_health
	%HPValue.text = str(new_health)
	
	if new_health <= 0:
		$GameOverScreen.visible = true

func _on_player_score_changed(new_score: int):
	var current_wave = str(SpawnManager.get_wave_number())
	var current_score = str(new_score)
	
	%Score.text = "Wave " + current_wave + "\nFinal Score\n" + current_score
	%CurrentScore.text = "Wave " + current_wave + "\nScore\n" + current_score
	
	var score_string_beginning: String = ""
	var score_string_end: String = ""
	var number_of_zeros: int = zeros_to_pad_score
	var new_score_string: String = str(new_score)
	
	if new_score != 0:
		number_of_zeros -= new_score_string.length()
	
	if number_of_zeros > 0:
		score_string_beginning += "[color=" + zero_color.to_html(false) + "]"
		
		for i in range(number_of_zeros):
			score_string_beginning += "0"
		
		score_string_beginning += "[/color]"
	
	if new_score != 0:
		score_string_end += "[color=" + score_color.to_html(false) + "]"
		score_string_end += new_score_string
		score_string_end += "[/color]"
	
	%Scoreboard.text = score_string_beginning + score_string_end

func _on_prepare_for_next_wave(next_wave_number: int):
	$WaveAnnouncer.text = "WAVE " + str(next_wave_number)
	
	var wave_tween = get_tree().create_tween()
	wave_tween.set_ease(Tween.EASE_IN)
	wave_tween.tween_property($WaveAnnouncer, "modulate:a", 1, wave_announcer_fade_time_seconds)
	$WaveAnnouncerWaitDelay.start()

func _on_wave_announcer_wait_delay_timeout():
	var wave_tween = get_tree().create_tween()
	wave_tween.set_ease(Tween.EASE_OUT)
	wave_tween.tween_property($WaveAnnouncer, "modulate:a", 0, wave_announcer_fade_time_seconds)

func show_power_up_indicator(text: String):
	$PowerUpAnnouncer.modulate.a = 0
	$PowerUpAnnouncer.text = text
	
	var tween = get_tree().create_tween()
	tween.tween_property($PowerUpAnnouncer, "modulate:a", 1, power_up_announcer_fade_time_seconds)
	
	await tween.finished
	
	$PowerUpAnnouncerWaitDelay.start()

func _on_player_fire_rose_picked_up():
	show_power_up_indicator("FLAME BARRIER")

func _on_player_haste_rose_picked_up():
	show_power_up_indicator("SUPER SPEED")

func _on_player_vision_rose_picked_up():
	show_power_up_indicator("ENHANCED VISION")

func _on_power_up_announcer_wait_delay_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property($PowerUpAnnouncer, "modulate:a", 0, power_up_announcer_fade_time_seconds)
