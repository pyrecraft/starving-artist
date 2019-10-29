extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')
const confirm_box = preload('res://ConfirmBox.tscn')

var state_L = Constants.State.PAINT
var confirm_node

# Called when the node enters the scene tree for the first time.
func _ready():
	store.create([
		{'name': 'game', 'instance': reducers},
		{'name': 'canvas', 'instance': reducers},
		{'name': 'paint', 'instance': reducers}
	], [
		{'name': '_on_store_changed', 'instance': self}
	])
	set_initial_canvas_dimensions()
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	state_L = init_state['game']['state']

func set_initial_canvas_dimensions():
	var viewport_size = get_viewport().size
	var offset_percentage = 30.0
	var canvas_x = int(viewport_size.x * ((100.0 - offset_percentage) / 100.0)) + 50
	var canvas_y = int(viewport_size.y * ((100.0 - offset_percentage) / 100.0)) - 100
	store.dispatch(actions.canvas_set_dimensions(Vector2(canvas_x, canvas_y)))
	var canvas_offset_x = int((viewport_size.x - canvas_x) / 2)
	var canvas_offset_y = int((viewport_size.y - canvas_y) / 2)
	store.dispatch(actions.canvas_set_starting_vector((Vector2(canvas_offset_x, canvas_offset_y))))

func _on_store_changed(name, state):
	if store.get_state() != null:
		if store.get_state()['game']['state'] != null:
			var next_state = store.get_state()['game']['state']
			print('State changed from %s to %s: ' % [str(state_L), str(next_state)])
			handle_state_changed(state_L, next_state)

func handle_state_changed(prev_state, next_state):
	match next_state:
		Constants.State.CONFIRM_CLEAR:
			confirm_node = confirm_box.instance()
			confirm_node.set_confirm_type(Constants.ConfirmBox.CLEAR)
			add_child(confirm_node)
		Constants.State.CLEAR:
			$Canvas.clear_canvas_art()
			store.dispatch(actions.game_set_state(Constants.State.PAINT))
		Constants.State.CONFIRM_SELL:
			confirm_node = confirm_box.instance()
			confirm_node.set_confirm_type(Constants.ConfirmBox.SELL)
			add_child(confirm_node)
		Constants.State.SELL:
			pass