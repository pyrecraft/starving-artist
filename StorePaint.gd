extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')
const confirm_box = preload('res://ConfirmBox.tscn')
const waku_font = preload('res://WakuWakuFontSmall.tres')
const hover_color = Color('#ff7e67')
const selected_color = Color('#ff5031')
const shadow_color = Color('#393e46')
const initial_vector = Vector2(65, 150)

var paint_list_L = []
var paint_info_L = {}
var current_paint_L = ''
var money_L = 0

var this_paint = ''
var is_assigned_color = false
var starting_vector = Vector2(65, 150)
var paint_offset_y = 110
var circle_radius = 40
var is_hover = false
var is_clicked = false
var is_removed = false
var paint_list_size
var paint_price

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

func instantiate(paint_list, paint_info, current_paint, money):
	paint_list_L = paint_list
	paint_info_L = paint_info
	current_paint_L = current_paint
	paint_list_size = paint_list_L.size()
	money_L = money

func assign_paint(starting_pos, color, price):
	this_paint = color
	is_assigned_color = true
	starting_vector = starting_pos
	paint_price = price
	$Area2D.position = starting_vector

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['paint']['paint_list'] != null:
		paint_list_L = store.get_state()['paint']['paint_list']
		update()
	if store.get_state()['paint']['paint_info'] != null:
		paint_info_L = store.get_state()['paint']['paint_info']
	if store.get_state()['paint']['current_paint'] != null:
		current_paint_L = store.get_state()['paint']['current_paint']
		update()
	if store.get_state()['game']['money'] != null:
		money_L = store.get_state()['game']['money']

func is_able_to_buy_paint():
#	print(paint_list_L)
#	print(this_paint)
#	print(paint_list_L.has(this_paint))
	return paint_list_L.size() < 8 and money_L >= int(paint_price) and !paint_list_L.has(this_paint)

func _draw():
	if !is_assigned_color or is_removed:
		return
	
	if is_able_to_buy_paint():
		if is_clicked:
			draw_circle(starting_vector, circle_radius * 1.15, selected_color)
		elif is_hover:
			draw_circle(starting_vector, circle_radius * 1.15, hover_color)
		
	draw_circle(starting_vector, circle_radius, Color(this_paint))
	
#	draw_string(waku_font, Vector2(starting_vector.x * 1.05, starting_vector.y * 1.06), \
#		'%s' % paint_percentage + '%', shadow_color)
	var text_offset = 10 * len(paint_price)
	draw_string(waku_font, Vector2(starting_vector.x - (0 + text_offset), starting_vector.y + 7), '$%s' % paint_price, \
		Color(this_paint).contrasted().lightened(0.5))
	
	if !is_able_to_buy_paint():
		var line_width = 10
		var x_offset = 35
		var y_offset = 35
		var x_color = Color.black
		draw_rounded_line(Vector2(starting_vector.x - x_offset, starting_vector.y - y_offset), Vector2(starting_vector.x + x_offset, starting_vector.y + y_offset), x_color, line_width)
		draw_rounded_line(Vector2(starting_vector.x + x_offset, starting_vector.y - y_offset), Vector2(starting_vector.x - x_offset, starting_vector.y + y_offset), x_color, line_width)

func draw_rounded_line(starting_vec, ending_vec, color, width):
	draw_line(starting_vec, ending_vec, color, width)
	draw_circle(starting_vec, width/2.0, color)
	draw_circle(ending_vec, width/2.0, color)

func _on_Area2D_mouse_entered():
	is_hover = true
	update()

func _on_Area2D_mouse_exited():
	is_hover = false
	is_clicked = false
	update()

func buy_paint():
	store.dispatch(actions.game_set_money(money_L - int(paint_price)))
	store.dispatch(actions.paint_add_paint(this_paint))
	store.dispatch(actions.paint_set_current_paint(this_paint))
	$AudioStreamPlayer.play()

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		is_clicked = true
		if is_able_to_buy_paint():
			buy_paint()
		update()