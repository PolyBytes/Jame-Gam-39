extends MarginContainer

const level = preload("res://Levels/Main/Main.tscn")

@onready var selector_one = $CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/Label
@onready var selector_two = $CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer2/Label
@onready var selector_three = $CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer3/Label

var current_selection = 0

func _ready():
	set_current_selection(0)

func _process(delta):
	if Input.is_action_just_pressed("ui_down") and current_selection < 2:
		current_selection += 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_up") and current_selection > 0:
		current_selection -= 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)

func handle_selection(_current_selection):
	if _current_selection == 0:
		get_parent().add_child(level.instance())
		queue_free()
	elif _current_selection == 1:
		print("Add options!")
	elif _current_selection == 2:
		get_tree().quit()

func set_current_selection(_current_selection):
	selector_one.text = ""
	selector_two.text = ""
	selector_three.text = ""
	if _current_selection == 0:
		selector_one.text = ">"
	elif _current_selection == 1:
		selector_two.text = ">"
	elif _current_selection == 2:
		selector_three.text = ">"