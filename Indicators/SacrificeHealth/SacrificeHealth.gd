extends Node2D

@export var sacrifice_y_offset: float = 15
@export var sacrifice_y_offset_time_seconds: float = 4

@export var amount: int = 0:
	set(value):
		amount = value
		start_animation()

func _ready():
	$RichTextLabel.visible = false

func start_animation():
	$RichTextLabel.text = "[center][color=ff0000]- " + str(amount) + " HP[/color][/center]"
	$RichTextLabel.visible = true
	
	var target_y_offset: float = position.y - sacrifice_y_offset
	
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "position:y", target_y_offset, sacrifice_y_offset_time_seconds)
	tween.parallel().tween_property(self, "modulate:a", 0, sacrifice_y_offset_time_seconds).set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free)
