extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')
const confirm_box = preload('res://ConfirmBox.tscn')
const canvas = preload('res://Canvas.tscn')
const sell_screen = preload('res://SellScreen.tscn')
const newspaper = preload('res://Newspaper.tscn')
const paint_store = preload('res://PaintStore.tscn')

var state_L = Constants.State.PAINT
var day_L
var previous_day
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
	day_L = init_state['game']['day']
	previous_day = day_L
#	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
#	$Background.queue_free()

func _process(delta):
#	print(Performance.get_monitor(Performance.TIME_FPS)) # Prints the FPS to the console
	pass

func set_initial_canvas_dimensions():
	var viewport_size = get_viewport().size
	var offset_percentage := 30.0
	var canvas_x = int(viewport_size.x * ((100.0 - offset_percentage) / 100.0)) + 50
	var canvas_y = int(viewport_size.y * ((100.0 - offset_percentage) / 100.0)) - 100
#	canvas_x = 535.5
#	canvas_x = 620
#	canvas_y = 480
	store.dispatch(actions.canvas_set_dimensions(Vector2(canvas_x, canvas_y)))
#	print(Vector2(canvas_x, canvas_y))
	var canvas_offset_x = int((viewport_size.x - canvas_x) / 2)
	var canvas_offset_y = int((viewport_size.y - canvas_y) / 2)
	store.dispatch(actions.canvas_set_starting_vector((Vector2(canvas_offset_x, canvas_offset_y))))
	store.dispatch(actions.canvas_set_grid(initialize_paint_grid()))
	store.dispatch(actions.game_set_mission(Constants.get_next_mission(day_L)))
	store.dispatch(actions.paint_set_random_paints_list(PaintConstants.get_random_paints_list()))
	$PaintManager.initialize_first_paints()

func _on_store_changed(name, state):
	if store.get_state() != null:
		if store.get_state()['game']['state'] != null:
			var next_state = store.get_state()['game']['state']
			handle_state_changed(state_L, next_state)
			state_L = store.get_state()['game']['state']
		if store.get_state()['game']['day'] != null:
			day_L = store.get_state()['game']['day']
#			if day_L == 11 and previous_day != day_L:
#				store.dispatch(actions.game_set_state(Constants.State.GAME_OVER))
#				previous_day = day_L

func handle_state_changed(prev_state, next_state):
	if prev_state == next_state:
		return
	match next_state:
		Constants.State.PAINT:
			$SellButton.show()
			$ClearButton.show()
			$PaintManager.show()
			$PaintStoreButton.show()
			$NewsButton.show()
		Constants.State.CONFIRM_CLEAR:
			confirm_node = confirm_box.instance()
			confirm_node.set_confirm_type(Constants.ConfirmBox.CLEAR)
			add_child(confirm_node)
		Constants.State.CLEAR:
			$Canvas.clear_canvas_art()
			store.dispatch(actions.game_set_state(Constants.State.PAINT))
			store.dispatch(actions.canvas_set_grid(initialize_paint_grid()))
#			print('Initializing brand new grid!')
		Constants.State.CONFIRM_SELL:
			confirm_node = confirm_box.instance()
			confirm_node.set_confirm_type(Constants.ConfirmBox.SELL)
			add_child(confirm_node)
		Constants.State.SELL:
			$SellButton.hide()
			$ClearButton.hide()
			$PaintStoreButton.hide()
			$NewsButton.hide()
			$PaintManager.hide()
			add_child(sell_screen.instance())
		Constants.State.NEXT_DAY:
			$Canvas.clear_canvas_art()
			store.dispatch(actions.paint_set_random_paints_list(PaintConstants.get_random_paints_list()))
			store.dispatch(actions.game_set_state(Constants.State.PAINT))
		Constants.State.NEWS:
			var news = newspaper.instance()
			add_child(news)
			if day_L == 11:
				$SellButton.hide()
				$ClearButton.hide()
				$PaintStoreButton.hide()
				$NewsButton.hide()
				$PaintManager.hide()
		Constants.State.STORE:
			var paint_store_inst = paint_store.instance()
			add_child(paint_store_inst)
		Constants.State.GAME_OVER:
			$SellButton.hide()
			$ClearButton.hide()
			$PaintStoreButton.hide()
			$NewsButton.hide()
			$PaintManager.hide()
			
			var news = newspaper.instance()
			add_child(news)

func initialize_paint_grid():
	var grid = []
	for y in range(get_viewport().size.y):
		grid.append([])
		for x in range(get_viewport().size.x):
			grid[y].append(null)
	return grid
