extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')
const waku_font = preload('res://WakuWakuFont.tres')
#const money_color = Color('#62d2a2')
const money_color = Color('#fbf0f0')
const money_shadow_color = Color('#393e46')

var day_L = 0
var font_position = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	day_L = init_state['game']['day']
	font_position = get_starting_font_position()

func get_starting_font_position():
	var font_border_offset = 0.05
	var viewport_size = get_viewport().size
	var border_offset_size = viewport_size * font_border_offset
	return Vector2(viewport_size.x - border_offset_size.x * 3.0, border_offset_size.y * 1.03)

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['game']['day'] != null:
		day_L = store.get_state()['game']['day']
		update()

func _draw():
	draw_string(waku_font, Vector2(font_position.x * 1.0025, font_position.y * 1.05), \
		'Day %s' % str(day_L), money_shadow_color)
	draw_string(waku_font, font_position, 'Day %s' % str(day_L), money_color)