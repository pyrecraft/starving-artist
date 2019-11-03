extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')

const button_inst = preload('res://Button.tscn')
const store_paint = preload('res://StorePaint.tscn')
const background_color = Color('#52616b')
const background_shadow_color = Color('#2a363b')

var starting_point
var dimensions

var paint_list_L
var paint_info_L
var current_paint_L
var random_paints_list_L
var money_L

var general_paints_index = 0
var random_paints_index = 0
var random_numbers_used = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var viewport_size = get_viewport().size
	starting_point = Vector2(viewport_size.x / 8.25, viewport_size.y / 8.0)
	dimensions = Vector2(viewport_size.x * (3.0/4.0), viewport_size.y * (2.0/3.0))
	
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	paint_list_L = store.get_state()['paint']['paint_list']
	paint_info_L = store.get_state()['paint']['paint_info']
	current_paint_L = store.get_state()['paint']['current_paint']
	random_paints_list_L = store.get_state()['paint']['random_paints_list']
	money_L = store.get_state()['game']['money']
	
	var close_button = button_inst.instance()
	add_child(close_button)
	close_button.set_box_position(Vector2(900, 60))
	close_button.set_box_dimensions(30, 30)
	close_button.set_text_offset_x(3)
	close_button.set_text_offset_y(4)
	close_button.set_text('X')
	close_button.set_colors(Color('#f85f73'), Color('#f63e56'))
	
	close_button.connect("clicked", self, "_on_CloseButton_clicked")
	
	load_paint_sale_children()

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['paint']['paint_list'] != null:
		paint_list_L = store.get_state()['paint']['paint_list']
	if store.get_state()['paint']['paint_info'] != null:
		paint_info_L = store.get_state()['paint']['paint_info']
	if store.get_state()['paint']['current_paint'] != null:
		current_paint_L = store.get_state()['paint']['current_paint']
	if store.get_state()['paint']['random_paints_list'] != null:
		random_paints_list_L = store.get_state()['paint']['random_paints_list']
	if store.get_state()['game']['money'] != null:
		money_L = store.get_state()['game']['money']

func load_paint_sale_children():
	general_paints_index = 0
	random_paints_index = 0
	random_numbers_used = []
	var x_offset = (dimensions.x - starting_point.x) / 4.0
	var y_offset = (dimensions.y - starting_point.y) / 4.0
	var x_buffer = 75
	var y_buffer = 75
	var x = starting_point.x + x_buffer 
	while x < dimensions.x + starting_point.x:
		var y = starting_point.y + y_buffer
		while y < dimensions.y + starting_point.y:
			var next_paint = store_paint.instance()
			next_paint.instantiate(paint_list_L, paint_info_L, current_paint_L, money_L)
			next_paint.assign_paint(Vector2(x, y), get_next_paint_to_display(), '100')
			add_child(next_paint)
			y += y_offset + y_buffer * (1.0/5.0)
		x += x_offset + x_buffer / 2

func get_next_paint_to_display():
	if general_paints_index < PaintConstants.GeneralPaints.size():
		general_paints_index += 1
		return PaintConstants.GeneralPaints[general_paints_index - 1]
	elif random_paints_index < 8:
		random_paints_index += 1
		return random_paints_list_L[random_paints_index - 1]
	else:
		return ''

func _input(event):
	if event is InputEventMouseButton:
		if event.position.x < starting_point.x or event.position.x > starting_point.x + dimensions.x:
			close_window()
		elif event.position.y < starting_point.y or event.position.y > starting_point.y + dimensions.y:
			close_window()

func _on_CloseButton_clicked():
	close_window()

func close_window():
	store.dispatch(actions.game_set_state(Constants.State.PAINT))
	queue_free()

func _draw():
	draw_rounded_rect(Rect2(starting_point, dimensions), background_shadow_color, 25)
	draw_rounded_rect(Rect2(starting_point, dimensions), background_color, 20)

func draw_rounded_line(starting_vec, ending_vec, color, width):
	draw_line(starting_vec, ending_vec, color, width)
	draw_circle(starting_vec, width/2.0, color)
	draw_circle(ending_vec, width/2.0, color)

func draw_rounded_rect(rect, color, circle_radius):
	draw_circle(rect.position, circle_radius, color)
	draw_circle(Vector2(rect.position.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_rect(Rect2(Vector2(rect.position.x - circle_radius, rect.position.y), \
		Vector2(rect.size.x + (circle_radius * 2), rect.size.y)), color)
	draw_rect(Rect2(Vector2(rect.position.x, rect.position.y - circle_radius), \
		Vector2(rect.size.x, rect.size.y + (circle_radius * 2))), color)