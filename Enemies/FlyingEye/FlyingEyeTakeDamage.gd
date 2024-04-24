extends AudioStreamPlayer2D

@export_category("Take Damage Sounds")
@export var sound_1: AudioStream
@export var sound_2: AudioStream
@export var sound_3: AudioStream

var sounds: Array

func _ready():
	assert(sound_1, "Sound 1 must be set.")
	assert(sound_2, "Sound 2 must be set.")
	assert(sound_3, "Sound 3 must be set.")
	
	sounds = [sound_1, sound_2, sound_3]

func play_random_sound():
	stream = sounds.pick_random()
	play()
