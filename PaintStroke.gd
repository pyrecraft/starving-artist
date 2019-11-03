extends Node2D

signal paint_out

const initial_state = preload('res://godot_redux/initial_state.gd')
const waku_font = preload('res://WakuWakuFontLarge.tres')

var color = Color.white
var color_hex
var draw_points = []
var grid_L = []
var paint_list_L
var paint_info_L
var current_paint_L

var paint_percentage
var prev_paint_percentage
var is_color_assigned = false
var emitted_signal = false

var is_showing_title = false
var indexes_added_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	if store.get_state() != null:
		grid_L = store.get_state()['canvas']['grid']
		paint_list_L = store.get_state()['paint']['paint_list']
		paint_info_L = store.get_state()['paint']['paint_info']
		current_paint_L = store.get_state()['paint']['current_paint']
	else:
		var init_state = initial_state.get_state()
		grid_L = init_state['canvas']['grid']
		paint_list_L = init_state['paint']['paint_list']
		paint_info_L = init_state['paint']['paint_info']
		current_paint_L = init_state['paint']['current_paint']

func instantiate(paint_list, paint_info, current_paint):
	paint_list_L = paint_list
	paint_info_L = paint_info
	current_paint_L = current_paint

func set_color(c):
	color = Color(c)
	color_hex = c
	is_color_assigned = true
	paint_percentage = paint_info_L[c]
	prev_paint_percentage = paint_percentage

func add_draw_point(pos, radius):
	var next_draw_point = DrawPoint.new(pos, radius, color)
	draw_points.append(next_draw_point)
	if is_color_assigned:
		paint_percentage -= sqrt(sqrt(radius)) / 2.0
	update()

func _draw():
	if paint_percentage <= 0:
		paint_done()
	for i in range(0, len(draw_points)):
		if i > 0:
			set_tangent_vector(draw_points[i-1], draw_points[i])
		if i > 1:
			pass
#			draw_connecting_rect(draw_points[i-2], draw_points[i-1])
#			add_line_to_paint_grid(draw_points[i-2], draw_points[i-1], i)
		draw_circle(draw_points[i].vec, draw_points[i].radius, draw_points[i].color)
#		add_square_to_paint_grid_index(draw_points[i].vec, draw_points[i].radius * 3.0, draw_points[i].color, i)
	if len(draw_points) > 1:
		var last_draw_point = draw_points[len(draw_points)-1]
		last_draw_point.set_tangent_vecs(Vector2(last_draw_point.vec.x - last_draw_point.radius, last_draw_point.vec.y), \
			Vector2(last_draw_point.vec.x + last_draw_point.radius, last_draw_point.vec.y))
		set_scapegoat_vector(draw_points[len(draw_points) - 2], last_draw_point)
#		draw_connecting_rect(draw_points[len(draw_points) - 2], last_draw_point)
#		add_line_to_paint_grid(draw_points[len(draw_points) - 2], last_draw_point, len(draw_points))

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

func update_grid_state():
	store.dispatch(actions.canvas_add_to_grid(grid_L))

func add_line_to_paint_grid(draw_point_one, draw_point_two, index):
	if index < indexes_added_count:
#		print('Already added index %s ' % str(index))
		return
	else:
#		print('Working on index %s ' % str(index))
		indexes_added_count = index
	var radius_average = max(draw_point_one.radius, draw_point_two.radius)
	var vector_distance = draw_point_one.vec.distance_to(draw_point_two.vec)
	if vector_distance < 20:
		return
	var step_count = min(sqrt(vector_distance) / radius_average, 10.0)
#	print('Vector Distance: %s' % vector_distance)
#	print('Radius: %s' % radius_average)
#	print('Step Count: %s' % step_count)
#	print('draw_point_one vec: %s' % draw_point_one.vec)
#	print('draw_point_two vec: %s' % draw_point_two.vec)
	
	var x_increment = abs((draw_point_two.vec.x - draw_point_one.vec.x) / float(step_count))
	var y_increment = abs((draw_point_two.vec.y - draw_point_one.vec.y) / float(step_count))
	var x = draw_point_one.vec.x
	var y = draw_point_one.vec.y
	
#	print('x_increment: %s' % x_increment)
#	print('y_increment: %s' % y_increment)
#	print('x: %s' % x)
#	print('y: %s' % y)
	
	if x < draw_point_two.vec.x and y < draw_point_two.vec.y:
		while (x < draw_point_two.vec.x and y < draw_point_two.vec.y):
			add_square_to_paint_grid(Vector2(x, y), radius_average, draw_point_one.color)
			y += y_increment
			x += x_increment
	elif x > draw_point_two.vec.x and y < draw_point_two.vec.y:
		while (x > draw_point_two.vec.x and y < draw_point_two.vec.y):
			add_square_to_paint_grid(Vector2(x, y), radius_average, draw_point_one.color)
			y += y_increment
			x -= x_increment
	elif x > draw_point_two.vec.x and y > draw_point_two.vec.y:
		while (x > draw_point_two.vec.x and y > draw_point_two.vec.y):
			add_square_to_paint_grid(Vector2(x, y), radius_average, draw_point_one.color)
			y -= y_increment
			x -= x_increment
	elif x < draw_point_two.vec.x and y > draw_point_two.vec.y:
		while (x < draw_point_two.vec.x and y > draw_point_two.vec.y):
#			print('Adding Square at %s' % Vector2(x, y))
			add_square_to_paint_grid(Vector2(x, y), radius_average, draw_point_one.color)
			y -= y_increment
			x += x_increment

func draw_connecting_rect(draw_point_one, draw_point_two):
	var tangent_arr = [
		draw_point_two.bottom_tangent_vec,
		draw_point_two.top_tangent_vec,
		draw_point_one.top_tangent_vec,
		draw_point_one.bottom_tangent_vec,
	]
	var shape = PoolVector2Array(sort_vec_array(tangent_arr))
	draw_colored_polygon(shape, draw_point_one.color)
	update()

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['canvas']['grid'] != null:
#		grid_L = store.get_state()['canvas']['grid']
		update()
	if store.get_state()['paint']['paint_list'] != null:
		paint_list_L = store.get_state()['paint']['paint_list']
	if store.get_state()['paint']['paint_info'] != null:
		paint_info_L = store.get_state()['paint']['paint_info']
	if store.get_state()['paint']['current_paint'] != null:
		current_paint_L = store.get_state()['paint']['current_paint']

func add_square_to_paint_grid(pos, rad, color):
	var diameter = rad * 2
	var x = pos.x - diameter
	while x < pos.x + diameter:
		var y = pos.y - diameter
		while y < pos.y + diameter:
			grid_L[y][x] = color
			y += 1
		x += 1

func add_square_to_paint_grid_index(pos, rad, color, index):
	if index < indexes_added_count:
#		print('Already added index %s ' % str(index))
		return
	else:
#		print('Working on index %s ' % str(index))
		indexes_added_count = index
	var diameter = rad * 2
	var x = pos.x - diameter
	while x < pos.x + diameter:
		var y = pos.y - diameter
		while y < pos.y + diameter:
			grid_L[y][x] = color
			y += 1
		x += 1

func sort_vec_array(vec_arr):
	var x_total = 0
	var y_total = 0
	for i in range(0, len(vec_arr)):
		x_total += vec_arr[i].x
		y_total += vec_arr[i].y
	var center = Vector2(x_total/4.0, y_total/4.0)
	
	var angles_arr = []
	for i in range(0, len(vec_arr)):
		angles_arr.append(center.angle_to_point(vec_arr[i]))
	
	angles_arr.sort()
	var res_arr = []
	
	for i in range(0, len(angles_arr)):
		var curr_angle = angles_arr[i]
		var has_found_angle = false
		for i in range(0, len(vec_arr)):
			var curr_vec = vec_arr[i]
			if curr_angle == center.angle_to_point(vec_arr[i]):
				if has_found_angle:
					return vec_arr
				res_arr.append(curr_vec)
				has_found_angle = true
	
	return res_arr

func set_scapegoat_vector(draw_point_one, draw_point_two):
	var angle_diff_radians = draw_point_one.vec.angle_to_point(draw_point_two.vec)

	var vector_magnitude = draw_point_one.vec.distance_to(draw_point_two.vec)
	vector_magnitude *= 1.1
	var scapegoat_vector_x = vector_magnitude * cos(angle_diff_radians)
	var scapegoat_vector_y = vector_magnitude * sin(angle_diff_radians)
	var scapegoat_vector = Vector2(scapegoat_vector_x, scapegoat_vector_y)
	
	var angle_diff_radians_two = draw_point_two.vec.angle_to_point(scapegoat_vector)

	var vec_two_diff_x = draw_point_two.radius * cos((PI/2.0) - angle_diff_radians_two)
	var vec_two_diff_y = draw_point_two.radius * sin((PI/2.0) - angle_diff_radians_two)
	var vec_two_top_tangent = Vector2(draw_point_two.vec.x - vec_two_diff_x, draw_point_two.vec.y + vec_two_diff_y)
	var vec_two_bottom_tangent = Vector2(draw_point_two.vec.x + vec_two_diff_y, draw_point_two.vec.y - vec_two_diff_y)
	draw_point_two.set_tangent_vecs(vec_two_top_tangent, vec_two_bottom_tangent)

func set_tangent_vector(draw_point_one, draw_point_two):
#	draw_line(draw_point_one.vec, draw_point_two.vec, color, draw_point_one.radius * 2)
	var angle = draw_point_one.vec.angle_to_point(draw_point_two.vec) * (180.0/PI)
	var angle_diff_radians = draw_point_one.vec.angle_to_point(draw_point_two.vec)
	
	var vec_one_diff_x = draw_point_one.radius * cos((PI/2.0) - angle_diff_radians)
	var vec_one_diff_y = draw_point_one.radius * sin((PI/2.0) - angle_diff_radians)
	var vec_one_top_tangent = Vector2(draw_point_one.vec.x - vec_one_diff_x, draw_point_one.vec.y + vec_one_diff_y)
	var vec_one_bottom_tangent = Vector2(draw_point_one.vec.x + vec_one_diff_x, draw_point_one.vec.y - vec_one_diff_y)
	
	draw_point_one.set_tangent_vecs(vec_one_top_tangent, vec_one_bottom_tangent)

class DrawPoint:
	var vec = Vector2(0, 0)
	var radius = 0
	var color = Color.white
	var top_tangent_vec = Vector2(0, 0)
	var bottom_tangent_vec = Vector2(0, 0)
	
	func _init(pos, rad, c):
		vec = pos
		radius = rad
		color = c
	
	func set_tangent_vecs(vec_one, vec_two):
		top_tangent_vec = vec_one
		bottom_tangent_vec = vec_two

func paint_done():
	if is_color_assigned and !emitted_signal and paint_percentage <= 0:
		var paint_info_copy = paint_info_L
		paint_info_copy[color_hex] = paint_percentage
		store.dispatch(actions.paint_set_paint_info(paint_info_copy))
		emitted_signal = true
		emit_signal('paint_out')
		$Timer.stop()

func _on_Timer_timeout():
	if emitted_signal:
		return
	if is_color_assigned and prev_paint_percentage != paint_percentage:
		if paint_percentage < 0:
			paint_percentage = 0
		var paint_info_copy = paint_info_L
		paint_info_copy[color_hex] = paint_percentage
		store.dispatch(actions.paint_set_paint_info(paint_info_copy))
		prev_paint_percentage = paint_percentage
		if paint_percentage == 0:
			emitted_signal = true
			emit_signal('paint_out')
			$Timer.stop()