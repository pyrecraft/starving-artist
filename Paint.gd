extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')
const waku_font = preload('res://WakuWakuFontSmall.tres')
const hover_color = Color('#ff7e67')
const selected_color = Color('#ff5031')
const shadow_color = Color('#393e46')
const initial_vector = Vector2(65, 150)

var paint_list_L = []
var paint_info_L = {}
var current_paint_L = ''

var this_paint = ''
var is_assigned_color = false
var starting_vector = Vector2(65, 150)
var paint_offset_y = 110
var circle_radius = 35
var is_hover = false
var is_removed = false
var paint_list_size

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	$Area2D.connect("mouse_entered", self, "_on_Area2D_mouse_entered")
	$Area2D.connect("mouse_exited", self, "_on_Area2D_mouse_exited")
	$Area2D.connect("input_event", self, "_on_Area2D_input_event")
#	paint_list_L = store.get_state()['paint']['paint_list']
#	paint_info_L = store.get_state()['paint']['paint_info']
#	current_paint_L = store.get_state()['paint']['current_paint']

func instantiate(paint_list, paint_info, current_paint):
	paint_list_L = paint_list
	paint_info_L = paint_info
	current_paint_L = current_paint
	paint_list_size = paint_list_L.size()

func assign_paint(color):
	this_paint = color
	is_assigned_color = true
	assign_starting_position()

func assign_starting_position():
	var index = -1
	for i in range(0, paint_list_L.size()):
#		print ('Checking %s' % paint_list_L[i])
		if paint_list_L[i] == this_paint:
			index = i
	if index == -1:
#		print('Assigned paint %s was never added to the paint_list!' % this_paint)
		return
	if index > 3:
		starting_vector.x = 1024 - initial_vector.x
	else:
		starting_vector.x = initial_vector.x
	starting_vector.y = initial_vector.y + paint_offset_y * (index % 4)
	$Area2D.position = starting_vector

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['paint']['paint_list'] != null:
		paint_list_L = store.get_state()['paint']['paint_list']
		if (paint_list_size != paint_list_L.size()):
			assign_starting_position()
			paint_list_size = paint_list_L.size()
		if is_assigned_color and !paint_list_L.has(this_paint):
			is_removed = true
			queue_free()
		update()
	if store.get_state()['paint']['paint_info'] != null:
		var previous_paint_info = paint_info_L
		paint_info_L = store.get_state()['paint']['paint_info']
		if is_assigned_color and !paint_info_L.has(this_paint):
			is_removed = true
			queue_free()
		elif is_assigned_color and previous_paint_info[this_paint] != paint_info_L[this_paint]:
			update()
	if store.get_state()['paint']['current_paint'] != null:
		current_paint_L = store.get_state()['paint']['current_paint']
		update()

func _draw():
	if !is_assigned_color or is_removed:
		return
	
	if current_paint_L == this_paint:
		draw_circle(starting_vector, circle_radius * 1.15, selected_color)
	elif is_hover:
		draw_circle(starting_vector, circle_radius * 1.15, hover_color)
		
	draw_circle(starting_vector, circle_radius, Color(this_paint))
	
	var paint_percentage = int(paint_info_L[this_paint])
#	draw_string(waku_font, Vector2(starting_vector.x * 1.05, starting_vector.y * 1.06), \
#		'%s' % paint_percentage + '%', shadow_color)
	var text_offset = 10 * len(str(paint_percentage))
	draw_string(waku_font, Vector2(starting_vector.x - (0 + text_offset), starting_vector.y + 7), '%s' % paint_percentage, \
		Color(this_paint).contrasted().lightened(0.5))

func _on_Area2D_mouse_entered():
	is_hover = true
	update()

func _on_Area2D_mouse_exited():
	is_hover = false
	update()

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		store.dispatch(actions.paint_set_current_paint(this_paint))
		update()