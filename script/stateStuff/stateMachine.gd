extends Node
class_name StateMachine

var states: Dictionary = {}
@export var initial_state: Node
@export var Player:player 
var current

func _ready() -> void: 
	for child in get_children():
		if child is state: 
			states[child.name] = child
			child.stateTransition.connect(changeState)
			child.Player = Player
	if initial_state:
		initial_state.start()
		current = initial_state

func changeState(oldState: state, newStateName: state):
	if oldState.name != current.name:
		print("invalid state change from: "+oldState.name+" but current state is "+current.name)
		return
	var newState = states.get(newStateName)
	if !newState:
		print("new state is empty")
		return
	if current:
		current.end()
	newState.start()
	current = newState

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current:
		current.Update(delta)
