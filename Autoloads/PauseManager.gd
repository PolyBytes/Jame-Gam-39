extends Node

var player: Player
var pause_screen: Control:
	set(node):
		pause_screen = node
		connect_slider_signals()

var music_volume_slider: HSlider
var master_volume_slider: HSlider

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if not Input.is_action_just_pressed("pause"):
		return
	
	if player.is_slain:
		return
	
	get_tree().paused = not get_tree().paused
	
	if not pause_screen:
		return
	
	pause_screen.visible = get_tree().paused

func connect_slider_signals():
	music_volume_slider = pause_screen.get_node("MusicVolumeSlider")
	music_volume_slider.value_changed.connect(music_volume_slider_changed)
	
	master_volume_slider = pause_screen.get_node("%MasterVolumeSlider")
	master_volume_slider.value_changed.connect(master_volume_slider_changed)

func music_volume_slider_changed(new_value: float):
	if new_value == music_volume_slider.min_value:
		Music.volume_db = -80
	else:
		Music.volume_db = new_value

func master_volume_slider_changed(new_value: float):
	if new_value == music_volume_slider.min_value:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -80)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), new_value)
