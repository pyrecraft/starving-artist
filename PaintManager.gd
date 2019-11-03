extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')
const paint_inst = preload('res://Paint.tscn')

const starting_paint_red = '#f85f73'
const starting_paint_blue = '#07689f'
const starting_paint_black = '#222831'
const starting_paint_yellow = '#f9ed69'
const starting_paint_brown = '#393232'

var paint_list_L
var paint_info_L
var current_paint_L

var children_paints = []

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	paint_list_L = init_state['paint']['paint_list']
	paint_info_L = init_state['paint']['paint_info']
	current_paint_L = init_state['paint']['current_paint']

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['paint']['paint_list'] != null:
		paint_list_L = store.get_state()['paint']['paint_list']
		if children_paints.size() < paint_list_L.size():
			for i in range(0, paint_list_L.size()):
				var next_paint = paint_list_L[i]
				if !children_paints.has(next_paint):
					var added_paint = paint_inst.instance()
					added_paint.instantiate(paint_list_L, paint_info_L, current_paint_L)
					added_paint.assign_paint(next_paint)
					add_child(added_paint)
					children_paints.append(next_paint)
		elif children_paints.size() > paint_list_L.size(): # Lazy
			children_paints = paint_list_L.duplicate(true)
	if store.get_state()['paint']['paint_info'] != null:
		paint_info_L = store.get_state()['paint']['paint_info']
	if store.get_state()['paint']['current_paint'] != null:
		current_paint_L = store.get_state()['paint']['current_paint']

func initialize_first_paints():
	store.dispatch(actions.paint_add_paint(starting_paint_red))
	store.dispatch(actions.paint_add_paint(starting_paint_blue))
	store.dispatch(actions.paint_add_paint(starting_paint_yellow))
	store.dispatch(actions.paint_add_paint(starting_paint_black))
	store.dispatch(actions.paint_add_paint(starting_paint_brown))
	store.dispatch(actions.paint_set_current_paint(starting_paint_red))
	
#	var red_paint_inst = paint_inst.instance()
#	red_paint_inst.instantiate(paint_list_L, paint_info_L, current_paint_L)
#	red_paint_inst.assign_paint(starting_paint_red)
#	add_child(red_paint_inst)
#
#	var blue_paint_inst = paint_inst.instance()
#	blue_paint_inst.instantiate(paint_list_L, paint_info_L, current_paint_L)
#	blue_paint_inst.assign_paint(starting_paint_blue)
#	add_child(blue_paint_inst)
#
#	var yellow_paint_inst = paint_inst.instance()
#	yellow_paint_inst.instantiate(paint_list_L, paint_info_L, current_paint_L)
#	yellow_paint_inst.assign_paint(starting_paint_yellow)
#	add_child(yellow_paint_inst)
#
#	var black_paint_inst = paint_inst.instance()
#	black_paint_inst.instantiate(paint_list_L, paint_info_L, current_paint_L)
#	black_paint_inst.assign_paint(starting_paint_black)
#	add_child(black_paint_inst)
#
#	var brown_paint_inst = paint_inst.instance()
#	brown_paint_inst.instantiate(paint_list_L, paint_info_L, current_paint_L)
#	brown_paint_inst.assign_paint(starting_paint_brown)
#	add_child(brown_paint_inst)