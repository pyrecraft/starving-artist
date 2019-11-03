extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')
const waku_font = preload('res://WakuWakuFont.tres')
const box_color = Color('#f85f73')
const box_clicked_color = Color('#f63e56')
const hover_color = Color('#ff7e67')
const money_shadow_color = Color('#393e46')

var money_L = 0
var font_position = Vector2(0, 0)
var box_position = Vector2(0, 0)
var box_dimensions = Vector2(0, 0)
var is_hover = false
var is_clicked = false
var is_sound_on = false
var last_playback_position = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D.connect("mouse_entered", self, "_on_Area2D_mouse_entered")
	$Area2D.connect("mouse_exited", self, "_on_Area2D_mouse_exited")
	$Area2D.connect("input_event", self, "_on_Area2D_input_event")
	
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	money_L = init_state['game']['money']
	box_dimensions = get_box_dimensions()
	box_position = get_box_position()
	font_position = get_starting_font_position()
	set_collision_shape()

func get_box_position():
	var font_border_offset = 0.015
	var viewport_size = get_viewport().size
	var border_offset_size = viewport_size * font_border_offset
	return Vector2(border_offset_size.x, (viewport_size.y - border_offset_size.y))

func get_box_dimensions():
	var box_height = 40
	var box_width = 160
	return Vector2(box_width, box_height)

func get_starting_font_position():
	var x_offset = 34
	return Vector2(box_position.x + x_offset, box_position.y + (box_dimensions.y * (3.75/5.0)))

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['game']['money'] != null:
		money_L = store.get_state()['game']['money']

func _draw():
	if is_hover:
		draw_music_symbol(box_position, 7, hover_color, true)
	draw_music_symbol(box_position, 5, Color.black, false)
	if !is_sound_on:
		var line_width = 5
		var x_offset = 10
		var y_offset = 10
		var x_color = Color('#f85f73')
		var starting_vec = Vector2(box_position.x + 11, box_position.y - 11)
		draw_rounded_line(Vector2(starting_vec.x - x_offset, starting_vec.y - y_offset), Vector2(starting_vec.x + x_offset, starting_vec.y + y_offset), x_color, line_width)
		draw_rounded_line(Vector2(starting_vec.x + x_offset, starting_vec.y - y_offset), Vector2(starting_vec.x - x_offset, starting_vec.y + y_offset), x_color, line_width)

func draw_rounded_line(starting_vec, ending_vec, color, width):
	draw_line(starting_vec, ending_vec, color, width)
	draw_circle(starting_vec, width/2.0, color)
	draw_circle(ending_vec, width/2.0, color)

func draw_music_symbol(starting_vec, radius, note_color, hover):
	draw_circle(starting_vec, radius * 1.1, note_color)
	draw_circle(Vector2(starting_vec.x + 20, starting_vec.y), radius * 1.1, note_color)
	draw_line(Vector2(starting_vec.x + 3, starting_vec.y + 2), Vector2(starting_vec.x + 3, starting_vec.y - 23), note_color, radius)
	draw_line(Vector2(starting_vec.x + 23, starting_vec.y + 2), Vector2(starting_vec.x + 23, starting_vec.y - 23), note_color, radius)
	if hover:
		draw_line(Vector2(starting_vec.x, starting_vec.y - 23), Vector2(starting_vec.x + 27, starting_vec.y - 23), note_color, radius * 1.5)
	else:
		draw_line(Vector2(starting_vec.x + 1, starting_vec.y - 23), Vector2(starting_vec.x + 26, starting_vec.y - 23), note_color, radius * 1.5)

func set_collision_shape():
	$Area2D/CollisionShape2D.position.x = box_position.x + 13
	$Area2D/CollisionShape2D.position.y = box_position.y - 13
#	$Area2D/CollisionShape2D.shape.extents = Vector2(box_dimensions.x / 1.9, box_dimensions.y / 1.6)

func draw_rounded_rect(rect, color, circle_radius):
	draw_circle(rect.position, circle_radius, color)
	draw_circle(Vector2(rect.position.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_rect(Rect2(Vector2(rect.position.x - circle_radius, rect.position.y), \
		Vector2(rect.size.x + (circle_radius * 2), rect.size.y)), color)
	draw_rect(Rect2(Vector2(rect.position.x, rect.position.y - circle_radius), \
		Vector2(rect.size.x, rect.size.y + (circle_radius * 2))), color)

func _on_Area2D_mouse_entered():
	is_hover = true
	update()

func _on_Area2D_mouse_exited():
	is_hover = false
	is_clicked = false
	update()

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if !is_clicked:
			is_clicked = true
		else:
			is_clicked = false
			is_sound_on = !$AudioStreamPlayer.playing
			if !is_sound_on:
				last_playback_position = $AudioStreamPlayer.get_playback_position()
				$AudioStreamPlayer.stop()
			else:
				$AudioStreamPlayer.play(last_playback_position)
		update()

func _on_MusicStartTimer_timeout():
	is_sound_on = true
	$AudioStreamPlayer.play()
	update()