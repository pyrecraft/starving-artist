extends Node2D

var color = Color.white
var draw_points = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
			draw_connecting_rect(draw_points[i-2], draw_points[i-1])
		draw_circle(draw_points[i].vec, draw_points[i].radius, draw_points[i].color)
	if len(draw_points) > 1:
		var last_draw_point = draw_points[len(draw_points)-1]
		last_draw_point.set_tangent_vecs(Vector2(last_draw_point.vec.x - last_draw_point.radius, last_draw_point.vec.y), \
			Vector2(last_draw_point.vec.x + last_draw_point.radius, last_draw_point.vec.y))
		set_scapegoat_vector(draw_points[len(draw_points) - 2], last_draw_point)
		draw_connecting_rect(draw_points[len(draw_points) - 2], last_draw_point)

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