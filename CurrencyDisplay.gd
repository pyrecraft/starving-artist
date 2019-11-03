extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')
const waku_font = preload('res://WakuWakuFont.tres')
const money_color = Color('#62d2a2')
const money_shadow_color = Color('#393e46')

var money_L = 0
var font_position = Vector2(0, 0)
var timer_index = 0
var slice_count = 19.0
var slice_amount = 0
var final_money_amount

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	money_L = init_state['game']['money']
	font_position = get_starting_font_position()

func get_starting_font_position():
	var font_border_offset = 0.05
	var viewport_size = get_viewport().size
	var border_offset_size = viewport_size * font_border_offset
	return Vector2(border_offset_size.x, border_offset_size.y * 1.03)

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['game']['money'] != null:
		var amount_diff = store.get_state()['game']['money'] - money_L
		final_money_amount = store.get_state()['game']['money']
#		money_L = store.get_state()['game']['money']
		timer_index = 0
		slice_amount = float(amount_diff) / slice_count
		$Timer.start()

func _draw():
	draw_string(waku_font, Vector2(font_position.x * 1.05, font_position.y * 1.06), \
		'$%s' % str(int(money_L)), money_shadow_color)
	draw_string(waku_font, font_position, '$%s' % str(int(money_L)), money_color)

func _on_Timer_timeout():
	timer_index += 1
	if timer_index == int(slice_count):
		money_L = final_money_amount
	else:
		money_L += slice_amount
		$Timer.start()
	update()
