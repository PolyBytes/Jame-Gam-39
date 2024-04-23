class_name FlyingEyeEnemy extends Enemy

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

var velocity: Vector2 = Vector2.ZERO
var look_direction: int = 1

func _ready():
	super()
	target_player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if not $EnemyStateMachine.current_state is FlyingEyeAttackState:
		$Sprite2D.flip_h = true if look_direction < 0 else false

func _on_enemy_state_machine_state_changed(new_state):
	if new_state is FlyingEyeFollowState:
		animation_state.travel("idle")
	elif new_state is FlyingEyeFlankState:
		pass
	elif new_state is FlyingEyeAttackState:
		animation_state.travel("attack")
	elif new_state is FlyingEyeStunnedState:
		animation_state.travel("take_damage")
	elif new_state is FlyingEyeSlainState:
		animation_state.travel("death")

func take_damage(damage_amount: int):
	if not is_alive:
		return
	
	super(damage_amount)
	stunned.emit()
