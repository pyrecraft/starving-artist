extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')

var color = Color.white
var draw_points = []
var grid_L = []

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	if store.get_state() != null and store.get_state()['canvas']['grid'] != null:
		grid_L = store.get_state()['canvas']['grid']
	else:
		var init_state = initial_state.get_state()
		grid_L = init_state['canvas']['grid']

func set_color(c):
	color = c

func add_draw_point(pos, radius):
	var next_draw_point = DrawPoint.new(pos, radius, color)
	draw_points.append(next_draw_point)
	update()

func _draw():
	for i in range(0, len(draw_points)):
		if i > 0:
			set_tangent_vector(draw_points[i-1], draw_points[i])
		if i > 1:
			pass
			draw_connecting_rect(draw_points[i-2], draw_points[i-1])
			add_line_to_paint_grid(draw_points[i-2], draw_points[i-1])
		draw_circle(draw_points[i].vec, draw_points[i].radius, draw_points[i].color)
		add_square_to_paint_grid(draw_points[i].vec, draw_points[i].radius, draw_points[i].color)
	if len(draw_points) > 1:
		var last_draw_point = draw_points[len(draw_points)-1]
		last_draw_point.set_tangent_vecs(Vector2(last_draw_point.vec.x - last_draw_point.radius, last_draw_point.vec.y), \
			Vector2(last_draw_point.vec.x + last_draw_point.radius, last_draw_point.vec.y))
		set_scapegoat_vector(draw_points[len(draw_points) - 2], last_draw_point)
		draw_connecting_rect(draw_points[len(draw_points) - 2], last_draw_point)
		add_line_to_paint_grid(draw_points[len(draw_points) - 2], last_draw_point)

func update_grid_state():
	store.dispatch(actions.canvas_set_grid(grid_L))

func add_line_to_paint_grid(draw_point_one, draw_point_two):
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
		grid_L = store.get_state()['canvas']['grid']
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