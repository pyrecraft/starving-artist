extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')

var money_L = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	money_L = init_state['game']['money']

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['game']['money'] != null:
		money_L = store.get_state()['game']['money']
