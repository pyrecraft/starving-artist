extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')
const waku_font = preload('res://WakuWakuFontLarge.tres')
const paint_stroke = preload('res://PaintStroke.tscn')
const test_colors = [Color.green, Color.white, Color.black, Color.aquamarine, Color.blanchedalmond]

var dimensions_L = Vector2(0, 0)
var starting_vector_L = Vector2(0, 0)
var grid_L = []
var state_L
var paint_list_L
var paint_info_L
var current_paint_L

var paint_strokes = []
var current_paint_stroke = null
var paint_radius = 15
var last_draw_point = Vector2(0, 0)
var last_radius = 5

func _ready():
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	dimensions_L = init_state['canvas']['dimensions']
	starting_vector_L = init_state['canvas']['starting_vector']
	grid_L = init_state['canvas']['grid']
	paint_list_L = init_state['paint']['paint_list']
	paint_info_L = init_state['paint']['paint_info']
	current_paint_L = init_state['paint']['current_paint']

func _process(delta):
	if state_L == Constants.State.PAINT:
		handle_input()

func get_random_color():
	randomize()
	return test_colors[randi() % len(test_colors)]

func clear_all_children():
	for c in get_children():
		c.queue_free()

func handle_input():
	if Input.is_action_just_pressed('ui_left'):
		if !is_vector_in_canvas(get_viewport().get_mouse_position()) or current_paint_L == '' or current_paint_L == null:
			return
		current_paint_stroke = paint_stroke.instance()
		current_paint_stroke.instantiate(paint_list_L, paint_info_L, current_paint_L)
		current_paint_stroke.set_color(current_paint_L)
		current_paint_stroke.connect("paint_out", self, "_on_PaintStroke_paint_out")
		add_child(current_paint_stroke)
		handle_mouse_draw()
	if Input.is_action_just_released('ui_left'):
		if current_paint_stroke != null:
			current_paint_stroke.update_grid_state()
		current_paint_stroke = null
#		last_draw_point = Vector2(0, 0)
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		if current_paint_stroke != null:
			handle_mouse_draw()

func is_next_point_close_to_last_one(last_point, next_point, radius):
	var x_diff = abs(last_point.x - next_point.x)
	var y_diff = abs(last_point.y - next_point.y)
	return x_diff < radius and y_diff < radius

func _on_PaintStroke_paint_out():
	if current_paint_stroke != null:
		store.dispatch(actions.paint_remove_color(current_paint_stroke.color_hex))
		current_paint_stroke.update_grid_state()
	current_paint_stroke = null
	last_draw_point = Vector2(0, 0)

func handle_mouse_draw():
	var current_mouse = get_viewport().get_mouse_position()
	if !is_vector_in_canvas(current_mouse):
		return
	elif is_next_point_close_to_last_one(last_draw_point, current_mouse, last_radius * 2.0):
		pass
	else:
		var next_radius = paint_radius - sqrt(randi() % 10) - 5
		if last_draw_point.x != 0 and last_draw_point.y != 0:
			var draw_point_diff = current_mouse.distance_to(last_draw_point)
			next_radius = paint_radius - sqrt(draw_point_diff)
			if next_radius < 0:
				next_radius = 2
			last_radius = next_radius
		current_paint_stroke.add_draw_point(current_mouse, next_radius)
#		add_square_to_paint_grid(current_mouse, next_radius, current_paint_stroke.color)
#		paint_grid_L[current_mouse.y][current_mouse.x] = current_paint_stroke.color
		last_draw_point = current_mouse
		update()

func add_square_to_paint_grid(pos, rad, color):
	var diameter = rad * 2
	var x = pos.x - diameter
	while x < pos.x + diameter:
		var y = pos.y - diameter
		while y < pos.y + diameter:
			grid_L[y][x] = color
			y += 1
		x += 1

#func add_circle_to_paint_grid(pos, rad, color):
#	var x = pos.x - rad
#	var y = pos.y - rad
#	var circle_points = get_circle_points(pos, rad)
#	print(str(circle_points))
#	while x < pos.x + rad:
#		while y < pos.y + rad:
#			pass

func has_existing_color(desired_color, desired_position):
	if grid_L[desired_position.y][desired_position.x] != null:
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
	if store.get_state()['canvas']['grid'] != null:
		grid_L = store.get_state()['canvas']['grid']
		update()
	if store.get_state()['game']['state'] != null:
		state_L = store.get_state()['game']['state']
	if store.get_state()['paint']['paint_list'] != null:
		paint_list_L = store.get_state()['paint']['paint_list']
	if store.get_state()['paint']['paint_info'] != null:
		paint_info_L = store.get_state()['paint']['paint_info']
	if store.get_state()['paint']['current_paint'] != null:
		current_paint_L = store.get_state()['paint']['current_paint']

func set_collision_shape():
	var collision_array = [Vector2(starting_vector_L.x, starting_vector_L.y),
		Vector2(starting_vector_L.x + dimensions_L.x, starting_vector_L.y),
		Vector2(starting_vector_L.x + dimensions_L.x, starting_vector_L.y + dimensions_L.y),
		Vector2(starting_vector_L.x, starting_vector_L.y + dimensions_L.y)]
	$Area2D/CollisionPolygon2D.polygon = PoolVector2Array(collision_array)

func get_circle_points(center, radius):
	var angle_from = 0
	var angle_to = 360
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	return points_arc

func _draw():
	if Constants.DEBUG_MODE:
		display_grid()
	var is_showing_title = false
	if is_showing_title:
		var font_position = Vector2(260, 200)
		var shadow_color = Color('#393e46')
#		draw_string(waku_font, Vector2(font_position.x * 1.01, font_position.y * 1.01), \
#			'Starving Artist', shadow_color)
#		draw_string(waku_font, font_position, 'Starving Artist', Color('#62d2a2'))
		draw_string(waku_font, Vector2(font_position.x * 1.01, font_position.y * 1.01), \
			'Starving', shadow_color)
		draw_string(waku_font, font_position, 'Starving', Color('#62d2a2'))
		font_position.y += 100
		font_position.x += 50
		draw_string(waku_font, Vector2(font_position.x * 1.01, font_position.y * 1.01), \
			'Artist', shadow_color)
		draw_string(waku_font, font_position, 'Artist', Color('#62d2a2'))
		var multiplier = 1.25
		var x_offset = 630
		var y_offset = 500
		var start_position = Vector2(220, 90)
		var end_position = Vector2(start_position.x * multiplier, start_position.y * multiplier)
#		draw_line(start_position, Vector2(start_position.x + x_offset * multiplier, start_position.y), Color.black, 1)
#		draw_line(start_position, Vector2(start_position.x, start_position.y + y_offset * multiplier), Color.black, 1)
#		draw_line(Vector2(start_position.x + x_offset * multiplier, start_position.y + y_offset * multiplier), Vector2(start_position.x + x_offset * multiplier, start_position.y), Color.black, 1)
#		draw_line(Vector2(start_position.x + x_offset * multiplier, start_position.y + y_offset * multiplier), Vector2(start_position.x, start_position.y + y_offset * multiplier), Color.black, 1)

#		draw_line(Vector2(827, 50), Vector2(827, 500), Color.black, 1)
#		draw_line(Vector2(197, 50), Vector2(197, 500), Color.black, 1)
#		draw_line(Vector2(197, 500), Vector2(827, 500), Color.black, 1)
		

func display_grid():
	for y in range(0, get_viewport().size.y):
		for x in range(0, get_viewport().size.x):
			if len(grid_L) > 0 and grid_L[y][x] != null:
				draw_circle(Vector2(x, y), 1, grid_L[y][x])