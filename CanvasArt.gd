extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')
const paint_stroke = preload('res://PaintStroke.tscn')
const test_colors = [Color.green, Color.white, Color.black, Color.aquamarine, Color.blanchedalmond]

var dimensions_L = Vector2(0, 0)
var starting_vector_L = Vector2(0, 0)
var paint_grid_L = []
var state_L

var paint_points = []

var paint_strokes = []
var current_paint_stroke = null
var paint_radius = 15
var last_draw_point = Vector2(0, 0)

func _ready():
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	dimensions_L = init_state['canvas']['dimensions']
	starting_vector_L = init_state['canvas']['starting_vector']
	initialize_paint_grid()

func _process(delta):
	if state_L == Constants.State.PAINT:
		handle_input()
#	print(Performance.get_monitor(Performance.TIME_FPS))

func get_random_color():
	randomize()
	return test_colors[randi() % len(test_colors)]

func handle_input():
	if Input.is_action_just_pressed('ui_left'):
		current_paint_stroke = paint_stroke.instance()
		current_paint_stroke.set_color(get_random_color())
		add_child(current_paint_stroke)
		handle_mouse_draw()
	if Input.is_action_just_released('ui_left'):
		current_paint_stroke = null
		last_draw_point = Vector2(0, 0)
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		if current_paint_stroke != null:
			handle_mouse_draw()

func handle_mouse_draw():
	var current_mouse = get_viewport().get_mouse_position()
	if !is_vector_in_canvas(current_mouse):
		return
	elif has_existing_color(current_paint_stroke.color, current_mouse):
		pass
	else:
		var next_radius = paint_radius - sqrt(randi() % 10) - 5
		if last_draw_point.x != 0 and last_draw_point.y != 0:
			var draw_point_diff = current_mouse.distance_to(last_draw_point)
			next_radius = paint_radius - sqrt(draw_point_diff)
			if next_radius < 0:
				next_radius = 2
		current_paint_stroke.add_draw_point(current_mouse, next_radius)
		paint_grid_L[current_mouse.y][current_mouse.x] = current_paint_stroke.color
		last_draw_point = current_mouse

func has_existing_color(desired_color, desired_position):
	if paint_grid_L[desired_position.y][desired_position.x] != null:
		return true
	else:
		return false

func is_vector_in_canvas(vec):
	if vec.x < starting_vector_L.x + 5 or vec.x > starting_vector_L.x + dimensions_L.x - 5:
		return false
	if vec.y < starting_vector_L.y - 70 or vec.y > starting_vector_L.y + dimensions_L.y - 80:
		return false
	return true

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['canvas']['dimensions'] != null:
		dimensions_L = store.get_state()['canvas']['dimensions']
	if store.get_state()['canvas']['starting_vector'] != null:
		starting_vector_L = store.get_state()['canvas']['starting_vector']
	if store.get_state()['game']['state'] != null:
		state_L = store.get_state()['game']['state']

func initialize_paint_grid():
	for y in range(get_viewport().size.y):
		paint_grid_L.append([])
		for x in range(get_viewport().size.x):
			paint_grid_L[y].append(null)

func set_collision_shape():
	var collision_array = [Vector2(starting_vector_L.x, starting_vector_L.y),
		Vector2(starting_vector_L.x + dimensions_L.x, starting_vector_L.y),
		Vector2(starting_vector_L.x + dimensions_L.x, starting_vector_L.y + dimensions_L.y),
		Vector2(starting_vector_L.x, starting_vector_L.y + dimensions_L.y)]
	$Area2D/CollisionPolygon2D.polygon = PoolVector2Array(collision_array)

func _draw():
	pass