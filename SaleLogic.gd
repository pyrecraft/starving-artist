extends Node

const initial_state = preload('res://godot_redux/initial_state.gd')

var dimensions_L = Vector2(0, 0)
var starting_vector_L = Vector2(0, 0)
var state_L
var grid_L

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	dimensions_L = init_state['canvas']['dimensions']
	starting_vector_L = init_state['canvas']['starting_vector']
	state_L = init_state['game']['state']
	grid_L = init_state['canvas']['grid']

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['canvas']['dimensions'] != null:
		dimensions_L = store.get_state()['canvas']['dimensions']
	if store.get_state()['canvas']['starting_vector'] != null:
		starting_vector_L = store.get_state()['canvas']['starting_vector']
	if store.get_state()['canvas']['grid'] != null:
		grid_L = store.get_state()['canvas']['grid']
		get_painting_sale_info()
	if store.get_state()['game']['state'] != null:
		state_L = store.get_state()['game']['state']

func get_painting_sale_info():
	var painting_info = PaintingInfo.new(starting_vector_L, dimensions_L, store.get_state()['canvas']['grid'])

func get_painting_sale_info_params(vec, dim, g):
	var painting_info = PaintingInfo.new(vec, dim, g)

func get_painting_sale_info_debug(grid):
	var painting_info = PaintingInfo.new(Vector2(129, 162), Vector2(766, 425), grid)

class PaintingInfo:
	var canvas_starting_point
	var canvas_dimensions = []
	var grid = []
	var canvas_coverage
	
	func _init(starting_point, dimens, paint_grid):
		canvas_starting_point = starting_point
		canvas_dimensions = dimens
		grid = paint_grid
		calculate_canvas_coverage()
	
	func calculate_canvas_coverage():
		if len(grid) == 0:
			return
		var point_count = 0
		for x in range(canvas_starting_point.x, canvas_starting_point.x + canvas_dimensions.x):
			for y in range(canvas_starting_point.y, canvas_starting_point.y + canvas_dimensions.y):
				if grid[y][x] != null:
					point_count += 1
		
		canvas_coverage = float(point_count) / (canvas_dimensions.x * canvas_dimensions.y)
		print('Canvas coverage is: %s percent' % str(canvas_coverage * 100))

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