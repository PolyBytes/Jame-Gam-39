class_name MushroomEnemy extends Enemy

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

var velocity: Vector2 = Vector2.ZERO
var look_direction: int = 1
var retreating: bool = false
var can_still_retreat: bool = true
var current_state: EnemyState

@export var attack_finished: bool = true

func _ready():
	super()
	target_player = get_tree().get_first_node_in_group("player")
	print(target_player)
	animation_state.travel("idle")

func _process(_delta):
	#if not $EnemyStateMachine.current_state is MushroomAttackState:
	if not retreating:
		$Sprite2D.flip_h = true if look_direction < 0 else false
	else:
		$Sprite2D.flip_h = false if look_direction < 0 else true
	
	if not monitoring:
		return
	
	if current_state is MushroomFollowState:
		if velocity.is_equal_approx(Vector2.ZERO):
			animation_state.travel("idle")
		else:
			animation_state.travel("run")

func _on_enemy_state_machine_state_changed(new_state):
	current_state = new_state
	
	if new_state is MushroomFollowState:
		pass
	elif new_state is MushroomAttackState:
		animation_state.travel("ranged_attack")
	elif new_state is MushroomStunnedState:
		animation_state.travel("take_damage")
	elif new_state is MushroomSlainState:
		animation_state.travel("death")

func take_damage(damage_amount: int):
	if not is_alive:
		return
	
	super(damage_amount)
	is_stunned = true
	$TakeDamage.play_random_sound()
	$AttackCooldownTimer.start()

func _on_area_entered(area):
	if area is MushroomRetreatArea:
		can_still_retreat = true

func _on_area_exited(area):
	if area is MushroomRetreatArea:
		can_still_retreat = false
