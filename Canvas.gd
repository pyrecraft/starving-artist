extends Node2D

const canvas_art = preload('res://CanvasArt.tscn')

const initial_state = preload('res://godot_redux/initial_state.gd')
const canvas_color = Color('#e8d8c3')
const easel_color = Color('#aa8f79')
const easel_shadow_color = Color('#aa8f79')

var dimensions_L = Vector2(0, 0)
var state_L

var canvas_art_instance

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	dimensions_L = init_state['canvas']['dimensions']
	state_L = init_state['game']['state']
	canvas_art_instance = canvas_art.instance()
	add_child(canvas_art_instance)

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['canvas']['dimensions'] != null:
		dimensions_L = store.get_state()['canvas']['dimensions']
	if store.get_state()['game']['state'] != null:
		state_L = store.get_state()['game']['state']
		if state_L == Constants.State.SELL:
			update()

func _draw():
	if state_L != Constants.State.SELL:
		draw_easel(0, easel_color)
	draw_blank_canvas()

func clear_canvas_art():
	canvas_art_instance.clear_all_children()
	canvas_art_instance.queue_free()
#	$Timer.start()
	canvas_art_instance = canvas_art.instance()
	add_child(canvas_art_instance)

func draw_easel(viewport_offset, color):
	var circle_radius = 15
	var border_offset_percent = .05
	var middle_offset_percent = .15
	var viewport_size = get_viewport().size
	
	var border_offset_size = viewport_size * border_offset_percent
	
	# top middle circle
	var top_point = Vector2(viewport_size.x / 2 - viewport_offset, border_offset_size.y - viewport_offset)
	draw_circle(top_point, circle_radius, color)
	
	# middle circle
	var mid_point = Vector2(viewport_size.x / 2 - viewport_offset, viewport_size.y / 2 - viewport_offset)
	draw_circle(mid_point, circle_radius, color)
	
	# bottom left circle
	var bottom_left_point = Vector2(mid_point.x - (viewport_size.x * middle_offset_percent), \
		viewport_size.y - border_offset_size.y - viewport_offset/2)
	draw_circle(bottom_left_point, circle_radius, color)
	
	# bottom right circle
	var bottom_right_point = Vector2(mid_point.x + (viewport_size.x * middle_offset_percent), \
		viewport_size.y - border_offset_size.y - viewport_offset/2)
	draw_circle(bottom_right_point, circle_radius, color)
	
	draw_line(top_point, mid_point, color, circle_radius * 2)
	draw_line(mid_point, bottom_left_point, color, circle_radius * 2)
	draw_line(mid_point, bottom_right_point, color, circle_radius * 2)

func draw_blank_canvas():
	if dimensions_L.x == 0 or dimensions_L.y == 0:
#		print('Skipping `draw_blank_canvas()` call because dimensions haven\'t been set yet')
		return
	var viewport_size = get_viewport().size
	var canvas_offset_x = int((viewport_size.x - dimensions_L.x) / 2)
	var canvas_offset_y = int((viewport_size.y - dimensions_L.y) / 2) - 75
	var circle_radius = 10
	
	# Easel background
	if state_L != Constants.State.SELL:
		draw_rounded_rect(Rect2(Vector2(viewport_size.x / 2.0 - (dimensions_L.x / 4.0), canvas_offset_y - 7), \
			Vector2(dimensions_L.x / 2, dimensions_L.y)), easel_shadow_color, circle_radius)
	draw_rounded_rect(Rect2(Vector2(canvas_offset_x, canvas_offset_y + 7), dimensions_L), easel_shadow_color, circle_radius)
	
	#Canvas
	draw_rounded_rect(Rect2(Vector2(canvas_offset_x, canvas_offset_y), dimensions_L), canvas_color, circle_radius)

func draw_rounded_rect(rect, color, circle_radius):
	draw_circle(rect.position, circle_radius, color)
	draw_circle(Vector2(rect.position.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_rect(Rect2(Vector2(rect.position.x - circle_radius, rect.position.y), \
		Vector2(rect.size.x + (circle_radius * 2), rect.size.y)), color)
	draw_rect(Rect2(Vector2(rect.position.x, rect.position.y - circle_radius), \
		Vector2(rect.size.x, rect.size.y + (circle_radius * 2))), color)

func _on_Timer_timeout():
	pass
#	canvas_art_instance = canvas_art.instance()
#	add_child(canvas_art_instance)
