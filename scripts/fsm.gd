extends Node

var debug = false
var STATES = {}
var state_cur = null
var state_nxt = null
var obj = null

func _init(obj : Object, states_parent_node : Node, initial_state, debug : bool = false) -> void:
	self.obj = obj
	self.debug = debug
	_set_states_parent_node(states_parent_node)
	state_nxt = initial_state

func _set_states_parent_node(pnode : Node):
#	if debug: print("Found ", pnode.get_child_count(), " states")
	if pnode.get_child_count() == 0:
		return
	var state_nodes = pnode.get_children()
	for state_node in state_nodes:
		#if debug: print("adding state: ", state_node.name)
		STATES[state_node.name] = state_node

func run_machine(delta : float) -> void:
	if state_nxt != state_cur:
		if state_cur != null:
#			if debug:
#				print(obj.name, ": changing from state ", state_cur.name, " to ", state_nxt.name)
			state_cur.terminate(obj)
#		elif debug:
#			print(obj.name, ": starting with state ", state_nxt.name)
		state_cur = state_nxt
		state_cur.initialize(obj)
		call_deferred("_update_state_label")
	# run state
	state_cur.run(obj, delta)

func _update_state_label() -> void:
	assert is_instance_valid(game.UI.player_state_label)
	game.UI.player_state_label.text = state_cur.name