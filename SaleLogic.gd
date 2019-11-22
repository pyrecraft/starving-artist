extends Node

const initial_state = preload('res://godot_redux/initial_state.gd')

var dimensions_L = Vector2(0, 0)
var starting_vector_L = Vector2(0, 0)
var state_L
var grid_L
var mission_L

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	dimensions_L = init_state['canvas']['dimensions']
	starting_vector_L = init_state['canvas']['starting_vector']
	state_L = init_state['game']['state']
	grid_L = init_state['canvas']['grid']
	mission_L = init_state['game']['mission']

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['canvas']['dimensions'] != null:
		dimensions_L = store.get_state()['canvas']['dimensions']
	if store.get_state()['canvas']['starting_vector'] != null:
		starting_vector_L = store.get_state()['canvas']['starting_vector']
	if store.get_state()['canvas']['grid'] != null:
		grid_L = store.get_state()['canvas']['grid']
#		get_painting_sale_info()
	if store.get_state()['game']['state'] != null:
		state_L = store.get_state()['game']['state']
	if store.get_state()['game']['mission'] != null:
		mission_L = store.get_state()['game']['mission']

func get_painting_sale_info():
	var painting_info = PaintingInfo.new(starting_vector_L, dimensions_L, store.get_state()['canvas']['grid'])
	var sale_price = get_sale_price(painting_info)
	var letter_grade = get_letter_grade(sale_price, mission_L.max_payout)
	return [sale_price, letter_grade] # [int, str]

func get_sale_price(info):
	var max_price = mission_L.max_payout
	match mission_L.criteria:
		Constants.Criteria.LARGE_COVERAGE:
			var coverage_amount = info.canvas_coverage
			return min(max_price, max_price * coverage_amount)
		Constants.Criteria.LOW_COVERAGE:
			var coverage_amount = info.canvas_coverage
			return min(max_price, max_price * (1.0 - coverage_amount))
		Constants.Criteria.DARK_COLORS:
			var coverage_amount = info.canvas_coverage
#			var coverage_boost = max(.2, coverage_amount / 2.0)
			return min(max_price, (max_price * ((1.0 - info.hsv_v_average)) * ((2.0 * coverage_amount))))
		Constants.Criteria.LIGHT_COLORS:
			var coverage_amount = info.canvas_coverage
#			var coverage_boost = max(.2, coverage_amount / 2.0)
			return min(max_price, (max_price * (info.hsv_v_average)) * (2.0 * coverage_amount))
		Constants.Criteria.COLOR_VARIETY:
			var coverage_amount = info.canvas_coverage
#			var coverage_boost = min(.2, coverage_amount / 2.0)
			return min(max_price, (max_price * (abs(info.color_variety/.5))) * (2.0 * coverage_amount))
		Constants.Criteria.RED_COLORS:
			var coverage_amount = info.canvas_coverage
#			var coverage_boost = min(.2, coverage_amount / 2.0)
			return min(max_price, (max_price * (info.red_average)) * (2.0 * coverage_amount))
		Constants.Criteria.BLUE_COLORS:
			var coverage_amount = info.canvas_coverage
#			var coverage_boost = min(.2, coverage_amount / 2.0)
			return min(max_price, (max_price * (info.blue_average)) * (2.0 * coverage_amount))
		Constants.Criteria.GREEN_COLORS:
			var coverage_amount = info.canvas_coverage
#			var coverage_boost = min(.2, coverage_amount / 2.0)
			return min(max_price, (max_price * (info.green_average)) * (2.0 * coverage_amount))
		Constants.Criteria.LEFT_COVERAGE:
			var total_coverage_amount = info.canvas_coverage
			var coverage_amount = info.left_coverage
			var right_coverage_amount = info.right_coverage
			return min(max_price, max_price * max(0, (coverage_amount - right_coverage_amount)))
		Constants.Criteria.RIGHT_COVERAGE:
			var total_coverage_amount = info.canvas_coverage
			var coverage_amount = info.right_coverage
			var left_coverage_amount = info.left_coverage
			return min(max_price, max_price * max(0, (coverage_amount - left_coverage_amount)))
		Constants.Criteria.GAME_END:
			return 1000
	return 0

func get_letter_grade(payout, max_payout):
	var percent = (payout / max_payout)
	if percent >= .95:
		return 'A+'
	elif percent > .9:
		return 'A'
	elif percent > .8:
		return 'B+'
	elif percent > .7:
		return 'B'
	elif percent > .6:
		return 'C+'
	elif percent > .5:
		return 'C'
	elif percent > .4:
		return 'D'
	else:
		return 'F'

func get_painting_sale_info_params(vec, dim, g):
	var painting_info = PaintingInfo.new(vec, dim, g)

func get_painting_sale_info_debug(grid):
	var painting_info = PaintingInfo.new(Vector2(129, 162), Vector2(766, 425), grid)

class PaintingInfo:
	var canvas_starting_point
	var canvas_dimensions = []
	var grid = []
	var canvas_coverage
	var left_coverage
	var right_coverage
	var hsv_v_average
	var red_average
	var green_average
	var blue_average
	var color_variety
	
	func _init(starting_point, dimens, paint_grid):
		canvas_starting_point = starting_point
		canvas_dimensions = dimens
		grid = paint_grid
		calculate_canvas_coverage()
	
	func calculate_canvas_coverage():
		if len(grid) == 0:
			return
		var point_count = 1.0
		var left_point_count = 1.0
		var right_point_count = 1.0
		var hsv_value_total = 0.0
		var red_total = 0.0
		var green_total = 0.0
		var blue_total = 0.0
		
		for x in range(canvas_starting_point.x, canvas_starting_point.x + canvas_dimensions.x):
			for y in range(canvas_starting_point.y, canvas_starting_point.y + canvas_dimensions.y):
				if grid[y][x] != null:
					var color = grid[y][x]
					point_count += 1
					if x < (canvas_dimensions.x / 2.0) + canvas_starting_point.x:
						left_point_count += 1
					elif x > (canvas_dimensions.x / 2.0) + canvas_starting_point.x:
						right_point_count += 1
					hsv_value_total += color.v
					red_total += color.r
					green_total += color.g
					blue_total += color.b
		
		canvas_coverage = float(point_count) / (canvas_dimensions.x * canvas_dimensions.y)
		left_coverage = float(left_point_count) / ((canvas_dimensions.x * canvas_dimensions.y) / 2.0)
		right_coverage = float(right_point_count) / ((canvas_dimensions.x * canvas_dimensions.y) / 2.0)
		hsv_v_average = hsv_value_total / point_count
		red_average = red_total / point_count
		green_average = green_total / point_count
		blue_average = blue_total / point_count
		color_variety = (red_average + green_average + blue_average) / 3.0
		
#		print('Canvas coverage is: %s percent' % str(canvas_coverage * 100))
#		print('Left Canvas coverage is: %s percent' % str(left_coverage * 100))
#		print('Right Canvas coverage is: %s percent' % str(right_coverage * 100))
#		print('HSV V (Brightness) average is: %s percent' % str(hsv_v_average * 100))
#		print('Red average is: %s percent' % str(red_average * 100))
#		print('Green average is: %s percent' % str(green_average * 100))
#		print('Blue average is: %s percent' % str(blue_average * 100))
#		print('Color variety is: %s percent' % str(color_variety * 100))

class ColorInfo:
	var color
	var coverage_percent
	var hue
	var saturation
	var value
	
	func _init(col, cov, h, s, v):
		color = col
		coverage_percent = cov
		hue = h
		saturation = s
		value = v