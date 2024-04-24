extends Control

@export_group("Scoreboard Properties")
@export var zeros_to_pad_score: int = 8
@export var score_color: Color = Color("ffffff")
@export var zero_color: Color = Color("6d6d6d")

@export_group("Power Bar Timers")
@export var vision_rose_timer: Timer

var target_health_percentage: float = 1
var current_health_percentage: float = 1
var health_lerp_speed: float = 2

func _ready():
	assert(vision_rose_timer, "Vision Rose Timer must be set.")
	
	%HealthBauble.material.set_shader_parameter("fill_per", current_health_percentage)
	_on_player_score_changed(0)

func _process(delta):
	if not is_equal_approx(current_health_percentage, target_health_percentage):
		current_health_percentage = lerpf(current_health_percentage, target_health_percentage, health_lerp_speed * delta)
		%HealthBauble.material.set_shader_parameter("fill_per", current_health_percentage)
	
	if vision_rose_timer.time_left > 0:
		%VisionRosePowerBar.material.set_shader_parameter("percentage", (vision_rose_timer.time_left / vision_rose_timer.wait_time))

func _on_player_health_changed(new_health, max_health):
	target_health_percentage = new_health as float / max_health

func _on_player_score_changed(new_score: int):
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
